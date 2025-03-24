import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import '../widgets/ping_results_table.dart';
import '../../providers/ping_providers.dart';
import 'settings_screen.dart';
import '../../providers/config_provider.dart';
import '../../utils/validation.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MacosColors.white,
      child: MacosWindow(
        backgroundColor: MacosColors.white,
        sidebar: Sidebar(
          minWidth: 130,
          maxWidth: 130,  // Match minWidth to prevent resizing
          topOffset: 28.0,  // Add space for window controls
          decoration: BoxDecoration(
            color: MacosColors.white,
            border: Border(
              right: BorderSide(
                color: MacosTheme.of(context).dividerColor,
              ),
            ),
          ),
          builder: (context, scrollController) {
            return Container(
              color: MacosColors.white,
              child: SidebarItems(
                currentIndex: _selectedIndex,
                scrollController: scrollController,
                itemSize: SidebarItemSize.large,
                onChanged: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
                items: const [
                  SidebarItem(
                    leading: MacosIcon(CupertinoIcons.chart_bar_fill),
                    label: Text('PingX'),
                  ),
                  SidebarItem(
                    leading: MacosIcon(CupertinoIcons.settings_solid),
                    label: Text('Settings'),
                  ),
                  SidebarItem(
                    leading: MacosIcon(CupertinoIcons.info_circle_fill),
                    label: Text('About'),
                  ),
                ],
              ),
            );
          },
        ),
        child: ContentArea(
          builder: (context, scrollController) {
            return IndexedStack(
              index: _selectedIndex,
              children: [
                DashboardView(controller: _controller),
                const SettingsView(),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      const MacosIcon(
                        CupertinoIcons.chart_bar_alt_fill,
                        size: 64,
                        color: MacosColors.systemGrayColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'PingX',
                        style: MacosTheme.of(context).typography.largeTitle.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Version 1.0.0',
                        style: MacosTheme.of(context).typography.body,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'A modern network diagnostic tool for macOS',
                        style: MacosTheme.of(context).typography.body,
                      ),
                      const SizedBox(height: 24),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Text(
                          'PingX helps you monitor network performance with features like CIDR range scanning, concurrent probing, and detailed latency analysis. Perfect for network administrators and developers.',
                          style: MacosTheme.of(context).typography.body,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const MacosIcon(CupertinoIcons.globe),
                          const SizedBox(width: 8),
                          Text(
                            'Built with Flutter and MacOS UI',
                            style: MacosTheme.of(context).typography.body,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const MacosIcon(CupertinoIcons.person_fill),
                          const SizedBox(width: 8),
                          Text(
                            'Developed by Jeffry',
                            style: MacosTheme.of(context).typography.body,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const MacosIcon(CupertinoIcons.mail_solid),
                          const SizedBox(width: 8),
                          Text(
                            'wangxin.jeffry@gmail.com',
                            style: MacosTheme.of(context).typography.body,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '\u00A9 2025 Jeffry Wang. All rights reserved.',
                        style: MacosTheme.of(context).typography.subheadline.copyWith(
                          color: MacosColors.systemGrayColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class DashboardView extends ConsumerWidget {
  final TextEditingController controller;

  const DashboardView({super.key, required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(pingResultsProvider);

    return MacosScaffold(
      toolBar: ToolBar(
        title: const Text('PingX'),
        titleWidth: 150.0,
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
              child: results.when(
                data: (data) => MacosScrollbar(
                  controller: scrollController,
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: MacosTheme.of(context).canvasColor,
                          border: Border.all(
                            color: MacosTheme.of(context).dividerColor,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Enter Hosts',
                              style: MacosTheme.of(context).typography.headline,
                            ),
                            const SizedBox(height: 16),
                            MacosTextField(
                              controller: controller,
                              placeholder:
                                  'Enter hosts (one per line) or CIDR ranges, separated by newlines. example:\n223.5.5.5\n8.8.8.8\ngoogle.com\n192.168.10.0/25',
                              maxLines: 5,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                PushButton(
                                  controlSize: ControlSize.large,
                                  onPressed: () {
                                    final text = controller.text;
                                    if (text.trim().isEmpty) return;

                                    final List<String> expandedHosts = [];
                                    bool hasError = false;

                                    // Process and validate each line
                                    for (final line in text.split('\n')) {
                                      final trimmed = line.trim();
                                      if (trimmed.isEmpty) continue;

                                      final validation = InputValidator.validateInput(trimmed);
                                      if (!validation.isValid) {
                                        hasError = true;
                                        // Show error dialog
                                        showMacosAlertDialog(
                                          context: context,
                                          builder: (context) => MacosAlertDialog(
                                            appIcon: const MacosIcon(
                                              CupertinoIcons.exclamationmark_triangle,
                                              color: MacosColors.systemRedColor,
                                            ),
                                            title: Text('Invalid Input'),
                                            message: Text('${trimmed}: ${validation.error ?? "Invalid input"}'),
                                            primaryButton: PushButton(
                                              controlSize: ControlSize.large,
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text('OK'),
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      // Handle CIDR expansion
                                      if (validation.type == 'cidr') {
                                        expandedHosts.addAll(
                                          InputValidator.expandCIDR(
                                            trimmed,
                                            skipFirstAddress: ref.read(configProvider).skipCidrFirstAddr,
                                            skipLastAddress: ref.read(configProvider).skipCidrLastAddr,
                                          ),
                                        );
                                      } else {
                                        expandedHosts.add(trimmed);
                                      }
                                    }

                                    if (!hasError && expandedHosts.isNotEmpty) {
                                      final manager = ref.read(pingManagerProvider);
                                      manager.startPinging(
                                        expandedHosts,
                                        ref.read(configProvider),
                                      );
                                    }
                                  },
                                  color: CupertinoColors.activeBlue,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      MacosIcon(
                                        CupertinoIcons.play_circle_fill,
                                        color: CupertinoColors.activeBlue,
                                      ),
                                      const SizedBox(width: 4),
                                      Text('Start Ping'),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                PushButton(
                                  controlSize: ControlSize.large,
                                  onPressed: () {
                                    final manager = ref.read(pingManagerProvider);
                                    manager.stopPinging();
                                  },
                                  color: CupertinoColors.systemRed,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      MacosIcon(
                                        CupertinoIcons.stop_circle_fill,
                                        color: CupertinoColors.systemRed,
                                      ),
                                      const SizedBox(width: 4),
                                      Text('Stop Ping'),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                PushButton(
                                  controlSize: ControlSize.large,
                                  onPressed: () {
                                    final manager = ref.read(pingManagerProvider);
                                    manager.clearResults();
                                    controller.clear();
                                  },
                                  color: CupertinoColors.systemOrange,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      MacosIcon(
                                        CupertinoIcons.trash_circle_fill,
                                        color: CupertinoColors.systemOrange,
                                      ),
                                      const SizedBox(width: 4),
                                      Text('Stop&Clear History'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: MacosTheme.of(context).canvasColor,
                          border: Border.all(
                            color: MacosTheme.of(context).dividerColor,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ping Results',
                              style: MacosTheme.of(context).typography.headline,
                            ),
                            const SizedBox(height: 16),
                            const PingResultsTable(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                loading: () => const Center(child: ProgressCircle()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            );
          },
        ),
      ],
    );
  }
}
