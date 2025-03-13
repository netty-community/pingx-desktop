import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import '../widgets/ping_results_table.dart';
import '../../providers/ping_providers.dart';
import 'settings_screen.dart';
import '../../providers/config_provider.dart';

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
    return MacosWindow(
      sidebar: Sidebar(
        minWidth: 200,
        builder: (context, scrollController) {
          return SidebarItems(
            currentIndex: _selectedIndex,
            onChanged: (index) {
              setState(() => _selectedIndex = index);
            },
            items: const [
              SidebarItem(
                leading: MacosIcon(CupertinoIcons.chart_bar),
                label: Text('PingX Dashboard'),
              ),
              SidebarItem(
                leading: MacosIcon(CupertinoIcons.settings),
                label: Text('Settings'),
              ),
              SidebarItem(
                leading: MacosIcon(CupertinoIcons.info_circle),
                label: Text('About'),
              ),
            ],
          );
        },
      ),
      child: IndexedStack(
        index: _selectedIndex,
        children: [
          DashboardView(controller: _controller),
          const SettingsView(),
          const Center(child: Text('About Page')),
        ],
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
      toolBar: ToolBar(title: const Text('PingX Dashboard')),
      children: [
        ContentArea(
          builder: (context, scrollController) {
            return results.when(
              data:
                  (data) => MacosScrollbar(
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
                                style:
                                    MacosTheme.of(context).typography.headline,
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
                                      final hosts =
                                          controller.text
                                              .split('\n')
                                              .map((e) => e.trim())
                                              .where((e) => e.isNotEmpty)
                                              .toList();

                                      if (hosts.isNotEmpty) {
                                        final manager = ref.read(
                                          pingManagerProvider,
                                        );
                                        manager.startPinging(
                                          hosts,
                                          ref.read(configProvider),
                                        );
                                      }
                                    },
                                    color: CupertinoColors.activeBlue,
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        MacosIcon(
                                          CupertinoIcons.play_circle_fill,
                                          color: CupertinoColors.activeBlue,
                                        ),
                                        SizedBox(width: 4),
                                        Text('Start Ping'),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  PushButton(
                                    controlSize: ControlSize.large,
                                    onPressed: () {
                                      final manager = ref.read(
                                        pingManagerProvider,
                                      );
                                      manager.stopPinging();
                                    },
                                    color: CupertinoColors.systemRed,
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        MacosIcon(
                                          CupertinoIcons.stop_circle_fill,
                                          color: CupertinoColors.systemRed,
                                        ),
                                        SizedBox(width: 4),
                                        Text('Stop Ping'),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  PushButton(
                                    controlSize: ControlSize.large,
                                    onPressed: () {
                                      final manager = ref.read(
                                        pingManagerProvider,
                                      );
                                      manager.clearResults();
                                      controller.clear();
                                    },
                                    color: CupertinoColors.systemOrange,
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        MacosIcon(
                                          CupertinoIcons.trash_circle_fill,
                                          color: CupertinoColors.systemOrange,
                                        ),
                                        SizedBox(width: 4),
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
                                style:
                                    MacosTheme.of(context).typography.headline,
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
            );
          },
        ),
      ],
    );
  }
}
