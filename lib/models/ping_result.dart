import 'dart:core';

class PingLog {
  final DateTime timestamp;
  final double rtt;
  final bool failed;
  final String hostname;
  final String ipAddr;
  final double latency;

  PingLog({
    required this.timestamp,
    required this.rtt,
    required this.failed,
    required this.hostname,
    required this.ipAddr,
    required this.latency,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'rtt': rtt,
    'failed': failed,
    'hostname': hostname,
    'ipAddr': ipAddr,
    'latency': latency,
  };
}

class PingResult {
  final String hostname;
  final String ipAddr;
  final DateTime startTime;
  int totalCount;
  int successCount;
  int failureCount;
  double failurePercent;
  bool lastPingFailed;
  double minLatency;
  double maxLatency;
  double avgLatency;
  double stdDevLatency;
  List<double> rtts;
  List<PingLog> pingLogs;
  final double _sumLatency = 0.0;
  final double _sumSquaredLatency = 0.0;

  double get sumLatency => _sumLatency;
  double get sumSquaredLatency => _sumSquaredLatency;

  PingResult({
    required this.hostname,
    required this.ipAddr,
    required this.startTime,
    this.totalCount = 0,
    this.successCount = 0,
    this.failureCount = 0,
    this.failurePercent = 0.0,
    this.lastPingFailed = false,
    this.minLatency = double.infinity,
    this.maxLatency = 0.0,
    this.avgLatency = 0.0,
    this.stdDevLatency = 0.0,
    List<double>? rtts,
    List<PingLog>? pingLogs,
  })  : rtts = rtts ?? <double>[],
        pingLogs = pingLogs ?? <PingLog>[];

  Map<String, dynamic> toJson() => {
    'hostname': hostname,
    'ipAddr': ipAddr,
    'startTime': startTime.toIso8601String(),
    'totalCount': totalCount,
    'successCount': successCount,
    'failureCount': failureCount,
    'failurePercent': failurePercent,
    'lastPingFailed': lastPingFailed,
    'minLatency': minLatency,
    'maxLatency': maxLatency,
    'avgLatency': avgLatency,
    'stdDevLatency': stdDevLatency,
    'pingLogs': pingLogs.map((log) => log.toJson()).toList(),
  };
}