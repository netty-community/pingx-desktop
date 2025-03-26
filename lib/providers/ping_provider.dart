import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ping_result.dart';

final pingResultsProvider = StateProvider<List<PingResult>>((ref) => []);

final selectedHostProvider = StateProvider<String?>((ref) => null);

final pingIntervalProvider = StateProvider<Duration>(
  (ref) => const Duration(seconds: 30),
);
