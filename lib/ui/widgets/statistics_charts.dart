import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import '../../models/ping_result.dart';

class StatisticsCharts extends ConsumerWidget {
  final String host;
  final List<PingResult> hostResults;

  const StatisticsCharts({
    super.key,
    required this.host,
    required this.hostResults,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = ScrollController();

    return Builder(
      builder: (context) {
        if (hostResults.isEmpty) {
          return const Center(child: Text('No data available'));
        }

        final result = hostResults.first;
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
              controller: scrollController,
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Statistics for $host',
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
                      'Last updated: ${DateTime.now().toString()}',
                      style: MacosTheme.of(context).typography.caption1.copyWith(
                            color: MacosTheme.of(context).typography.caption1.color?.withOpacity(0.7),
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
                                border: Border.all(color: MacosTheme.of(context).dividerColor),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Network Information',
                                    style: MacosTheme.of(context).typography.subheadline,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildStatRow(context, "Hostname", result.hostname),
                                  _buildStatRow(context, 'IP Address', result.ipAddr),
                                  _buildStatRow(context, 'Status', result.lastPingFailed ? 'Failed' : 'Success'),
                                  _buildStatRow(context, 'Total Pings', result.totalCount.toString()),
                                  _buildStatRow(context, 'Failed Pings', result.failureCount.toString()),
                                  _buildStatRow(context, 'Failure Rate', '${result.failurePercent.toStringAsFixed(1)}%'),
                                  _buildStatRow(context, 'Last Ping', result.lastPingFailed ? 'Failed' : 'Success'),
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
                                border: Border.all(color: MacosTheme.of(context).dividerColor),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Response Time Statistics',
                                    style: MacosTheme.of(context).typography.subheadline,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildStatRow(context, 'MinRTT(ms)', '${result.minLatency.toStringAsFixed(2)} ms'),
                                  _buildStatRow(context, 'MaxRTT(ms)', '${result.maxLatency.toStringAsFixed(2)} ms'),
                                  _buildStatRow(context, 'AverageRTT(ms)', '${result.avgLatency.toStringAsFixed(2)} ms'),
                                  _buildStatRow(context, 'Jitter(ms)', '${result.stdDevLatency.toStringAsFixed(2)} ms'),
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
                        border: Border.all(color: MacosTheme.of(context).dividerColor),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Response Time History',
                            style: MacosTheme.of(context).typography.subheadline,
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 300,
                            child: _buildResponseTimeChart(result),
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
                  color: MacosTheme.of(context).typography.body.color?.withOpacity(0.7),
                ),
          ),
          const Spacer(),
          Text(
            value,
            style: MacosTheme.of(context).typography.body,
          ),
        ],
      ),
    );
  }

  Widget _buildResponseTimeChart(PingResult result) {
    if (result.pingLogs.isEmpty) return const SizedBox.shrink();

    final startTime = result.startTime.millisecondsSinceEpoch.toDouble();
    final spots = result.pingLogs.map((log) {
      return FlSpot(
        log.timestamp.millisecondsSinceEpoch.toDouble() - startTime,
        log.failed ? 0 : log.rtt / 1000, // Convert microseconds to milliseconds
      );
    }).toList();

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            dotData: FlDotData(show: false),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            axisNameWidget: const Text('Time (mm:ss)'),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              interval: 3000, // 3 seconds interval
              getTitlesWidget: (value, meta) {
                final seconds = (value / 1000).floor();
                final minutes = (seconds / 60).floor();
                final remainingSeconds = seconds % 60;
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 10, // Add some extra space between labels
                  child: Text(
                    '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            axisNameWidget: const Text('RTT (ms)'),
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
      ),
    );
  }
}
