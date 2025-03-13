import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import '../../providers/ping_providers.dart';
import '../../models/ping_result.dart';

class StatisticsCharts extends ConsumerWidget {
  final String host;

  const StatisticsCharts({super.key, required this.host});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(pingResultsProvider);

    return results.when(
      data: (data) {
        final hostResults = data.where((result) => result.hostname == host).toList();
        if (hostResults.isEmpty) {
          return const Center(child: Text('No data available'));
        }

        final result = hostResults.first;
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 8),
              Text(
                'Last updated: ${DateTime.now().toString()}',
                style: MacosTheme.of(context).typography.caption1.copyWith(
                      color: MacosTheme.of(context).typography.caption1.color?.withOpacity(0.7),
                    ),
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        children: [
                          Text(
                            'Response Time Statistics',
                            style: MacosTheme.of(context).typography.headline,
                          ),
                          const SizedBox(height: 16),
                          _buildStatRow(context, 'Minimum', '${result.minLatency.toStringAsFixed(2)} ms'),
                          _buildStatRow(context, 'Maximum', '${result.maxLatency.toStringAsFixed(2)} ms'),
                          _buildStatRow(context, 'Average', '${result.avgLatency.toStringAsFixed(2)} ms'),
                          _buildStatRow(context, 'Jitter', '${result.stdDevLatency.toStringAsFixed(2)} ms'),
                          _buildStatRow(context, 'Success Rate', '${((1 - result.failurePercent) * 100).toStringAsFixed(1)}%'),
                          const SizedBox(height: 16),
                          Text(
                            'Network Information',
                            style: MacosTheme.of(context).typography.headline,
                          ),
                          const SizedBox(height: 16),
                          _buildStatRow(context, 'IP Address', result.ipAddr),
                          _buildStatRow(context, 'Status', result.lastPingFailed ? 'Failed' : 'Success'),
                          _buildStatRow(context, 'Total Pings', result.totalCount.toString()),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
                      style: MacosTheme.of(context).typography.headline,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: _buildResponseTimeChart(result),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: ProgressCircle()),
      error: (error, stack) => Center(child: Text('Error: $error')),
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
    final spots = result.pingLogs.asMap().entries.map((entry) {
      return FlSpot(
        entry.key.toDouble(),
        entry.value.failed ? 0 : entry.value.rtt,
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
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
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
