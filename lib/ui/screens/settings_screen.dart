import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import '../../providers/config_provider.dart';

class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(configProvider);
    final configNotifier = ref.read(configProvider.notifier);

    return MacosScaffold(
      toolBar: ToolBar(
        title: const Text('Settings'),
        decoration: BoxDecoration(
          color: MacosColors.white,
          border: Border(
            bottom: BorderSide(
              color: MacosTheme.of(context).dividerColor,
            ),
          ),
        ),
      ),
      backgroundColor: MacosColors.white,
      children: [
        ContentArea(
          builder: (context, scrollController) {
            return Container(
              color: MacosColors.white,
              child: MacosScrollbar(
                controller: scrollController,
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      'Probe Settings',
                      style: MacosTheme.of(context).typography.headline,
                    ),
                    const SizedBox(height: 20),
                    _buildNumberField(
                      context: context,
                      label: 'Interval (ms)',
                      value: config.interval,
                      onChanged: (value) => configNotifier.updateInterval(value),
                      min: 100,
                      max: 10000,
                    ),
                    _buildNumberField(
                      context: context,
                      label: 'Count',
                      value: config.count,
                      onChanged: (value) => configNotifier.updateCount(value),
                      min: 1,
                      max: 100,
                    ),
                    _buildNumberField(
                      context: context,
                      label: 'Timeout (s)',
                      value: config.timeout,
                      onChanged: (value) => configNotifier.updateTimeout(value),
                      min: 1,
                      max: 30,
                    ),
                    _buildNumberField(
                      context: context,
                      label: 'Packet Size',
                      value: config.size,
                      onChanged: (value) => configNotifier.updateSize(value),
                      min: 16,
                      max: 1024,
                    ),
                    _buildNumberField(
                      context: context,
                      label: 'Wait Between Probes (s)',
                      value: config.wait,
                      onChanged: (value) => configNotifier.updateWait(value),
                      min: 1,
                      max: 60,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Performance Settings',
                      style: MacosTheme.of(context).typography.headline,
                    ),
                    const SizedBox(height: 20),
                    _buildNumberField(
                      context: context,
                      label: 'Max Store Logs',
                      value: config.maxStoreLogs,
                      onChanged: (value) => configNotifier.updateMaxStoreLogs(value),
                      min: 10,
                      max: 1000,
                    ),
                    _buildNumberField(
                      context: context,
                      label: 'Max Concurrent Probes',
                      value: config.maxConcurrentProbes,
                      onChanged: (value) => configNotifier.updateMaxConcurrentProbes(value),
                      min: 1,
                      max: 1000,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'CIDR Settings',
                      style: MacosTheme.of(context).typography.headline,
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          PushButton(
                            controlSize: ControlSize.regular,
                            padding: const EdgeInsets.all(8),
                            color: config.skipCidrFirstAddr ? const Color.fromARGB(255, 228, 232, 237) : MacosColors.transparent,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (config.skipCidrFirstAddr)
                                  const MacosIcon(
                                    CupertinoIcons.checkmark,
                                    color: MacosColors.white,
                                    size: 16,
                                  ),
                              ],
                            ),
                            onPressed: () => configNotifier.updateSkipCidrFirstAddr(!config.skipCidrFirstAddr),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Skip First Address in CIDR Range',
                            style: MacosTheme.of(context).typography.body,
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          PushButton(
                            controlSize: ControlSize.regular,
                            padding: const EdgeInsets.all(8),
                            color: config.skipCidrLastAddr ? const Color.fromARGB(255, 228, 232, 237) : MacosColors.transparent,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (config.skipCidrLastAddr)
                                  const MacosIcon(
                                    CupertinoIcons.checkmark,
                                    color: MacosColors.white,
                                    size: 16,
                                  ),
                              ],
                            ),
                            onPressed: () => configNotifier.updateSkipCidrLastAddr(!config.skipCidrLastAddr),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Skip Last Address in CIDR Range',
                            style: MacosTheme.of(context).typography.body,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildNumberField({
    required BuildContext context,
    required String label,
    required int value,
    required Function(int) onChanged,
    required int min,
    required int max,
  }) {
    final controller = TextEditingController(text: value.toString());
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: MacosTextField(
                  placeholder: 'Enter value',
                  controller: controller,
                  onChanged: (text) {
                    final newValue = int.tryParse(text);
                    if (newValue != null && newValue >= min && newValue <= max) {
                      onChanged(newValue);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              MacosTooltip(
                message: 'Range: $min - $max',
                child: const MacosIcon(CupertinoIcons.info_circle),
              ),
            ],
          ),
        ],
      ),
    );
  }
}