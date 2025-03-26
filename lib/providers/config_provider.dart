import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/config.dart';

class ConfigNotifier extends StateNotifier<ProbeConfig> {
  ConfigNotifier() : super(const ProbeConfig());

  void updateConfig(ProbeConfig newConfig) {
    state = newConfig;
  }

  void updateInterval(int value) {
    state = state.copyWith(interval: value);
  }

  void updateCount(int value) {
    state = state.copyWith(count: value);
  }

  void updateTimeout(int value) {
    state = state.copyWith(timeout: value);
  }

  void updateSize(int value) {
    state = state.copyWith(size: value);
  }

  void updateWait(int value) {
    state = state.copyWith(wait: value);
  }

  void updateMaxStoreLogs(int value) {
    state = state.copyWith(maxStoreLogs: value);
  }

  void updateMaxConcurrentProbes(int value) {
    state = state.copyWith(maxConcurrentProbes: value);
  }

  void updateSkipCidrFirstAddr(bool value) {
    state = state.copyWith(skipCidrFirstAddr: value);
  }

  void updateSkipCidrLastAddr(bool value) {
    state = state.copyWith(skipCidrLastAddr: value);
  }
}

final configProvider = StateNotifierProvider<ConfigNotifier, ProbeConfig>((
  ref,
) {
  return ConfigNotifier();
});
