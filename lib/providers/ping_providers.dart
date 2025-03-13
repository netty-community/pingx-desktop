import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ping_manager.dart';
import '../models/ping_result.dart';

final pingManagerProvider = Provider<PingManager>((ref) => PingManager());

final pingResultsProvider = StreamProvider<List<PingResult>>((ref) {
  final manager = ref.watch(pingManagerProvider);

  return Stream.periodic(
    const Duration(milliseconds: 500),
    (_) => manager.getResults(),
  ).distinct((prev, next) {
    if (prev.length != next.length) return false;

    for (var i = 0; i < prev.length; i++) {
      final prevResult = prev[i];
      final nextResult = next[i];

      if (prevResult.totalCount != nextResult.totalCount ||
          prevResult.successCount != nextResult.successCount ||
          prevResult.failureCount != nextResult.failureCount ||
          prevResult.lastPingFailed != nextResult.lastPingFailed ||
          prevResult.minLatency != nextResult.minLatency ||
          prevResult.maxLatency != nextResult.maxLatency ||
          prevResult.avgLatency != nextResult.avgLatency ||
          prevResult.stdDevLatency != nextResult.stdDevLatency ||
          prevResult.pingLogs.length != nextResult.pingLogs.length) {
        return false;
      }
    }
    return true;
  });
});
