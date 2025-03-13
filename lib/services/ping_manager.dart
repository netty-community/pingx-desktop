import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:dart_ping/dart_ping.dart';
import '../models/ping_result.dart';
import '../models/config.dart';

class PingManager {
  final Map<String, PingResult> _results = {};
  final Map<String, Ping> _activeProbes = {};
  bool _isRunning = false;
  Timer? _updateTimer;
  Timer? _cleanupTimer;

  static const int _defaultWait = 3; // 3 second
  static const int _maxHistory = 100; // Keep last 100 pings
  static const int _maxHostsInMemory = 50; // Maximum number of hosts to track

  // Singleton pattern
  static final PingManager _instance = PingManager._internal();
  factory PingManager() => _instance;
  PingManager._internal() {
    // Start the update timer immediately
    _startUpdateTimer();
    // Start memory cleanup timer
    _startMemoryCleanupTimer();
  }

  bool get isRunning => _isRunning;
  int get activeHostCount => _results.length;
  List<String> get activeHosts => _results.keys.toList();

  Future<void> startPinging(List<String> hosts, ProbeConfig config) async {
    _isRunning = true;

    // Limit number of hosts in memory
    final hostsToTrack = hosts.take(_maxHostsInMemory).toList();
    final maxProbes = min(config.maxConcurrentProbes, _maxHostsInMemory);
    final activeHosts = hostsToTrack.take(maxProbes).toList();

    for (final host in activeHosts) {
      if (!_activeProbes.containsKey(host)) {
        final hostAddress = await _resolveHostname(host);
        _results[host] = PingResult(
          hostname: host,
          ipAddr: hostAddress,
          startTime: DateTime.now(),
        );
        _startPingProbe(host, config);
      }
    }
  }

  void _startUpdateTimer() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      // Create new instances of each result to force update
      for (final host in _results.keys.toList()) {
        final result = _results[host]!;
        _results[host] = PingResult(
          hostname: result.hostname,
          ipAddr: result.ipAddr,
          startTime: result.startTime,
          totalCount: result.totalCount,
          successCount: result.successCount,
          failureCount: result.failureCount,
          failurePercent: result.failurePercent,
          lastPingFailed: result.lastPingFailed,
          minLatency: result.minLatency,
          maxLatency: result.maxLatency,
          avgLatency: result.avgLatency,
          stdDevLatency: result.stdDevLatency,
          rtts: List<double>.from(result.rtts),
          pingLogs: List<PingLog>.from(result.pingLogs),
        );
      }
    });
  }

  void _startMemoryCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _cleanupOldResults();
    });
  }

  void _cleanupOldResults() {
    final now = DateTime.now();
    final List<String> hostsToRemove = [];

    // Find inactive hosts older than 1 hour
    for (final entry in _results.entries) {
      if (!_activeProbes.containsKey(entry.key)) {
        final lastPingTime =
            entry.value.pingLogs.isEmpty
                ? entry.value.startTime
                : entry.value.pingLogs.last.timestamp;

        if (now.difference(lastPingTime).inHours >= 1) {
          hostsToRemove.add(entry.key);
        }
      }
    }

    // Remove inactive hosts
    for (final host in hostsToRemove) {
      _results.remove(host);
    }
  }

  void removeHost(String hostname) {
    _activeProbes[hostname]?.stop();
    _activeProbes.remove(hostname);
    _results.remove(hostname);
  }

  PingResult? getHostResult(String hostname) => _results[hostname];

  List<PingResult> getResults({bool activeOnly = false}) {
    if (activeOnly) {
      return _activeProbes.keys
          .map((host) => _results[host])
          .whereType<PingResult>()
          .toList();
    }
    return _results.values.toList();
  }

  void dispose() {
    stopPinging();
    clearResults();
    _updateTimer?.cancel();
    _cleanupTimer?.cancel();
  }

  void stopPinging() {
    _isRunning = false;
    for (final probe in _activeProbes.values) {
      probe.stop();
    }
    _activeProbes.clear();
  }

  void clearResults() {
    stopPinging();
    _results.clear();
  }

  void _startPingProbe(String host, ProbeConfig config) async {
    // Stop any existing probe
    _activeProbes[host]?.stop();
    _activeProbes.remove(host);

    while (_isRunning) {
      // Configure new ping for single operation
      final ping = Ping(
        host,
        count: config.count, // Single ping
        timeout: config.timeout,
        ttl: config.ttl,
      );

      try {
        // Wait for single ping result
        final event = await ping.stream.first;

        if (event.error != null) {
          _handlePingError(host);
        } else {
          _handlePingResponse(host, event);
        }
      } catch (error) {
        _handlePingError(host);
      }

      // Store ping instance
      _activeProbes[host] = ping;

      // Wait for configured interval before next ping
      await Future.delayed(Duration(seconds: config.wait ?? _defaultWait));
    }
  }

  Future<String> _resolveHostname(String host) async {
    try {
      final addresses = await InternetAddress.lookup(host);
      return addresses.first.address;
    } catch (e) {
      return 'Unknown';
    }
  }

  void _handlePingResponse(String host, PingData event) {
    if (!_results.containsKey(host)) return;

    final result = _results[host]!;
    result.totalCount++;

    final response = event.response;
    if (response != null && response.time != null) {
      result.successCount++;
      result.lastPingFailed = false;

      final rtt =
          response.time!.inMicroseconds / 1000.0; // Convert to milliseconds
      result.rtts.add(rtt);

      // Update min/max latency
      if (result.minLatency == 0 || rtt < result.minLatency) {
        result.minLatency = rtt;
      }
      result.maxLatency = max(result.maxLatency, rtt);

      // Calculate average
      result.avgLatency =
          result.rtts.reduce((a, b) => a + b) / result.rtts.length;

      // Calculate standard deviation
      final mean = result.avgLatency;
      final variance =
          result.rtts.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) /
          result.rtts.length;
      result.stdDevLatency = sqrt(variance);
    } else {
      result.lastPingFailed = true;
    }

    result.failureCount = result.totalCount - result.successCount;
    result.failurePercent = result.failureCount / result.totalCount;

    // Add to ping logs
    result.pingLogs.add(
      PingLog(
        timestamp: DateTime.now(),
        rtt: response?.time?.inMicroseconds.toDouble() ?? 0,
        failed: response?.time == null,
        hostname: result.hostname,
        ipAddr: result.ipAddr,
        latency: response?.time?.inMicroseconds.toDouble() ?? 0,
      ),
    );

    // Keep only last N ping logs
    if (result.pingLogs.length > _maxHistory) {
      result.pingLogs.removeAt(0);
    }

    // Keep only last N RTTs
    if (result.rtts.length > _maxHistory) {
      result.rtts.removeAt(0);
    }

    // Create a new instance to force update
    _results[host] = PingResult(
      hostname: result.hostname,
      ipAddr: result.ipAddr,
      startTime: result.startTime,
      totalCount: result.totalCount,
      successCount: result.successCount,
      failureCount: result.failureCount,
      failurePercent: result.failurePercent,
      lastPingFailed: result.lastPingFailed,
      minLatency: result.minLatency,
      maxLatency: result.maxLatency,
      avgLatency: result.avgLatency,
      stdDevLatency: result.stdDevLatency,
      rtts: List<double>.from(result.rtts),
      pingLogs: List<PingLog>.from(result.pingLogs),
    );
  }

  void _handlePingError(String host) {
    if (!_results.containsKey(host)) return;

    final result = _results[host]!;
    result.totalCount++;
    result.failureCount++;
    result.lastPingFailed = true;
    result.failurePercent = result.failureCount / result.totalCount;

    // Add to ping logs
    result.pingLogs.add(
      PingLog(
        timestamp: DateTime.now(),
        rtt: 0,
        failed: true,
        hostname: result.hostname,
        ipAddr: result.ipAddr,
        latency: result.avgLatency,
      ),
    );

    // Keep only last N ping logs
    if (result.pingLogs.length > _maxHistory) {
      result.pingLogs.removeAt(0);
    }

    // Create a new instance to force update
    _results[host] = PingResult(
      hostname: result.hostname,
      ipAddr: result.ipAddr,
      startTime: result.startTime,
      totalCount: result.totalCount,
      successCount: result.successCount,
      failureCount: result.failureCount,
      failurePercent: result.failurePercent,
      lastPingFailed: result.lastPingFailed,
      minLatency: result.minLatency,
      maxLatency: result.maxLatency,
      avgLatency: result.avgLatency,
      stdDevLatency: result.stdDevLatency,
      rtts: List<double>.from(result.rtts),
      pingLogs: List<PingLog>.from(result.pingLogs),
    );
  }
}
