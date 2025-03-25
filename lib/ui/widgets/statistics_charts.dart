import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import '../../models/ping_result.dart';
import '../../providers/ping_provider.dart';

class StatisticsCharts extends ConsumerStatefulWidget {
  final String host;
  final List<PingResult> hostResults;

  const StatisticsCharts({
    super.key,
    required this.host,
    required this.hostResults,
  });

  @override
  ConsumerState<StatisticsCharts> createState() => _StatisticsChartsState();
}

class _StatisticsChartsState extends ConsumerState<StatisticsCharts> {
  late final MacosTabController _tabController;
  late final ScrollController _mainScrollController;
  late final ScrollController _logsScrollController;

  @override
  void initState() {
    super.initState();
    _tabController = MacosTabController(
      initialIndex: 0,
      length: 2,
    );
    _mainScrollController = ScrollController();
    _logsScrollController = ScrollController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _mainScrollController.dispose();
    _logsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch ping results and interval to trigger rebuild
    ref.watch(pingResultsProvider);
    final pingInterval = ref.watch(pingIntervalProvider);
    
    return Builder(
      builder: (context) {
        if (widget.hostResults.isEmpty) {
          return const Center(child: Text('No data available'));
        }

        final latestResult = widget.hostResults.first;
        final allPingLogs =
            widget.hostResults.expand((result) => result.pingLogs).toList();

        final minRtt = allPingLogs
            .where((log) => !log.failed)
            .map((log) => log.rtt)
            .reduce((a, b) => a < b ? a : b);
        final maxRtt = allPingLogs
            .where((log) => !log.failed)
            .map((log) => log.rtt)
            .reduce((a, b) => a > b ? a : b);
        final avgRtt =
            allPingLogs
                .where((log) => !log.failed)
                .map((log) => log.rtt)
                .reduce((a, b) => a + b) /
            allPingLogs.where((log) => !log.failed).length;

        final variance =
            allPingLogs
                .where((log) => !log.failed)
                .map((log) => (log.rtt - avgRtt) * (log.rtt - avgRtt))
                .reduce((a, b) => a + b) /
            allPingLogs.where((log) => !log.failed).length;
        final stdDev = variance > 0 ? math.sqrt(variance) : 0;

        return Focus(
          autofocus: true,
          onKeyEvent: (node, event) {
            if (event.logicalKey == LogicalKeyboardKey.escape) {
              Navigator.of(context).pop();
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            child: MacosScrollbar(
              controller: _mainScrollController,
              child: SingleChildScrollView(
                controller: _mainScrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Statistics for ${widget.host}',
                          style: MacosTheme.of(context).typography.title1,
                        ),
                        const Spacer(),
                        PushButton(
                          controlSize: ControlSize.small,
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Last updated: ${DateTime.now().toLocal().toString().split('.')[0]}',
                      style: MacosTheme.of(
                        context,
                      ).typography.caption1.copyWith(
                        color: MacosTheme.of(
                          context,
                        ).typography.caption1.color?.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 16),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Container(
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
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Network Information',
                                    style:
                                        MacosTheme.of(
                                          context,
                                        ).typography.subheadline,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildStatRow(
                                    context,
                                    "Hostname",
                                    latestResult.hostname,
                                  ),
                                  _buildStatRow(
                                    context,
                                    'IP Address',
                                    latestResult.ipAddr,
                                  ),
                                  _buildStatRow(
                                    context,
                                    'Status',
                                    latestResult.lastPingFailed
                                        ? 'Failed'
                                        : 'Success',
                                  ),
                                  _buildStatRow(
                                    context,
                                    'Total Pings',
                                    latestResult.totalCount.toString(),
                                  ),
                                  _buildStatRow(
                                    context,
                                    'Failed Pings',
                                    latestResult.failureCount.toString(),
                                  ),
                                  _buildStatRow(
                                    context,
                                    'Failure Rate',
                                    '${latestResult.failurePercent.toStringAsFixed(1)}%',
                                  ),
                                  _buildStatRow(
                                    context,
                                    'Last Ping',
                                    latestResult.lastPingFailed
                                        ? 'Failed'
                                        : 'Success',
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
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
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Response Time Statistics',
                                    style:
                                        MacosTheme.of(
                                          context,
                                        ).typography.subheadline,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildStatRow(
                                    context,
                                    'MinRTT(ms)',
                                    '${(minRtt / 1000).toStringAsFixed(2)} ms',
                                  ),
                                  _buildStatRow(
                                    context,
                                    'MaxRTT(ms)',
                                    '${(maxRtt / 1000).toStringAsFixed(2)} ms',
                                  ),
                                  _buildStatRow(
                                    context,
                                    'AverageRTT(ms)',
                                    '${(avgRtt / 1000).toStringAsFixed(2)} ms',
                                  ),
                                  _buildStatRow(
                                    context,
                                    'Jitter(ms)',
                                    '${(stdDev / 1000).toStringAsFixed(2)} ms',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
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
                          MacosTabView(
                            controller: _tabController,
                            tabs: const [
                              MacosTab(
                                label: 'Response Time History',
                                active: true,
                              ),
                              MacosTab(
                                label: 'Ping Logs',
                                active: false,
                              ),
                            ],
                            children: [
                              // Response Time History Tab
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    height: 300,
                                    child: _buildResponseTimeChart(widget.hostResults, pingInterval),
                                  ),
                                ],
                              ),
                              // Ping Logs Tab
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    height: 300,
                                    child: _buildPingLogsTable(allPingLogs),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: MacosTheme.of(context).typography.body.copyWith(
              color: MacosTheme.of(
                context,
              ).typography.body.color?.withOpacity(0.7),
            ),
          ),
          const Spacer(),
          Text(value, style: MacosTheme.of(context).typography.body),
        ],
      ),
    );
  }

  Widget _buildResponseTimeChart(List<PingResult> results, Duration pingInterval) {
    if (results.isEmpty) return const SizedBox.shrink();

    final allPingLogs = results.expand((result) => result.pingLogs).toList();
    final startTime = allPingLogs.first.timestamp.millisecondsSinceEpoch.toDouble();
    
    // Calculate max RTT for y-axis scale
    final maxRtt = allPingLogs
        .where((log) => !log.failed)
        .map((log) => log.rtt / 1000) // Convert to ms
        .fold(0.0, (max, value) => value > max ? value : max);
    
    // Round up to nearest multiple of 100 for cleaner scale
    final yAxisMax = ((maxRtt + 99) ~/ 100) * 100.0;
    
    final spots = allPingLogs.map((log) {
      return FlSpot(
        log.timestamp.millisecondsSinceEpoch.toDouble() - startTime,
        log.failed ? 0 : log.rtt / 1000, // Convert microseconds to milliseconds
      );
    }).toList();

    return LineChart(
      LineChartData(
        minY: 0, // Start y-axis from 0
        maxY: yAxisMax, // Use calculated max
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 2,
                  color: const Color.fromARGB(255, 105, 127, 212),
                  strokeWidth: 1,
                  strokeColor: MacosTheme.of(context).canvasColor,
                );
              },
            ),
            color: MacosColors.systemBlueColor,
            belowBarData: BarAreaData(
              show: true,
              color: MacosColors.systemBlueColor.withOpacity(0.1),
            ),
            barWidth: 2,
          ),
        ],
        titlesData: FlTitlesData(
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            axisNameWidget: const Text(
              'Response Time (ms)',
              style: TextStyle(fontSize: 12),
            ),
            axisNameSize: 24,
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              interval: yAxisMax / 5, // Show 5 intervals on y-axis
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            axisNameWidget: const Text(
              'Time',
              style: TextStyle(fontSize: 12),
            ),
            axisNameSize: 24,
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              interval: pingInterval.inMilliseconds.toDouble(),
              getTitlesWidget: (value, meta) {
                final seconds = (value / 1000).floor();
                final minutes = (seconds / 60).floor();
                final remainingSeconds = seconds % 60;
                return Text(
                  '$minutes:${remainingSeconds.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: yAxisMax / 10, // More grid lines for better readability
          verticalInterval: pingInterval.inMilliseconds.toDouble(),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: MacosTheme.of(context).dividerColor),
        ),
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: MacosTheme.of(context).canvasColor,
            tooltipRoundedRadius: 8,
            tooltipBorder: BorderSide(
              color: MacosTheme.of(context).dividerColor,
            ),
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            tooltipMargin: -30, // Move tooltip below the point
            getTooltipItems: (spots) {
              return spots.map((spot) {
                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(1)} ms',
                  TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPingLogsTable(List<PingLog> logs) {
    return MacosScrollbar(
      controller: _logsScrollController,
      child: SingleChildScrollView(
        controller: _logsScrollController,
        child: Table(
          border: TableBorder(
            horizontalInside: BorderSide(
              color: MacosColors.systemGrayColor.withOpacity(0.2),
            ),
          ),
          columnWidths: const {
            0: FlexColumnWidth(2), // Timestamp
            1: FlexColumnWidth(1), // RTT
            2: FlexColumnWidth(1), // Status
          },
          children: [
            TableRow(
              decoration: BoxDecoration(
                color: MacosColors.systemGrayColor.withOpacity(0.1),
              ),
              children: [
                _buildTableHeader('Timestamp'),
                _buildTableHeader('RTT (ms)'),
                _buildTableHeader('Status'),
              ],
            ),
            ...logs.map((log) => TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: Text(
                    log.timestamp.toLocal().toString().split('.')[0],
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: Text(
                    log.failed ? '-' : (log.rtt / 1000).toStringAsFixed(2),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: Text(
                    log.failed ? 'Failed' : 'Success',
                    style: TextStyle(
                      fontSize: 12,
                      color: log.failed ? MacosColors.systemRedColor : MacosColors.systemGreenColor,
                    ),
                  ),
                ),
              ],
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
