import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';
import '../../providers/ping_providers.dart';
import '../../models/ping_result.dart';
import './statistics_charts.dart';

class SuccessRateBar extends StatelessWidget {
  final int success;
  final int total;
  static const double _successThreshold = 90.0;

  const SuccessRateBar({super.key, required this.success, required this.total});

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (success / total * 100) : 0.0;
    final widthFactor = total > 0 ? (success / total).clamp(0.0, 1.0) : 0.0;
    final color =
        percentage >= _successThreshold
            ? CupertinoColors.systemGreen
            : CupertinoColors.systemRed;

    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$success/$total',
            style: MacosTheme.of(context).typography.body,
          ),
        ),
        Expanded(
          child: Container(
            height: 16,
            decoration: BoxDecoration(
              color: MacosTheme.of(context).dividerColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: widthFactor,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 60,
          child: Text(
            '${percentage.toStringAsFixed(1)}%',
            textAlign: TextAlign.right,
            style: MacosTheme.of(context).typography.body,
          ),
        ),
      ],
    );
  }
}

class PingStatusIndicator extends StatelessWidget {
  final bool lastPingFailed;

  const PingStatusIndicator({super.key, required this.lastPingFailed});

  @override
  Widget build(BuildContext context) {
    final color =
        lastPingFailed
            ? CupertinoColors.systemRed
            : CupertinoColors.systemGreen;
    final text = lastPingFailed ? 'Failed' : 'Success';

    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}

class PingResultsTable extends ConsumerWidget {
  const PingResultsTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(pingResultsProvider);

    return results.when(
      data:
          (data) => Container(
            decoration: BoxDecoration(
              color: MacosTheme.of(context).canvasColor,
              border: Border.all(color: MacosTheme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Table(
                  border: TableBorder(
                    horizontalInside: BorderSide(
                      color: MacosTheme.of(context).dividerColor,
                    ),
                  ),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: const {
                    0: FlexColumnWidth(1.2), // Hostname
                    1: FlexColumnWidth(1.0), // IP
                    2: FlexColumnWidth(1.8), // Success Rate
                    3: FlexColumnWidth(1.0), // Status
                    4: FlexColumnWidth(0.9), // Min
                    5: FlexColumnWidth(0.9), // Max
                    6: FlexColumnWidth(0.9), // Avg
                    7: FlexColumnWidth(0.9), // Jitter
                    8: FlexColumnWidth(0.6), // Actions
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: MacosTheme.of(
                          context,
                        ).primaryColor.withOpacity(0.1),
                      ),
                      children: const [
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Hostname', textAlign: TextAlign.left),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'IP Address',
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Ping Success Rate',
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Last Status',
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'MinRTT(ms)',
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'MaxRTT(ms)',
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'AvgRTT(ms)',
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Jitter(ms)',
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Actions', textAlign: TextAlign.left),
                          ),
                        ),
                      ],
                    ),
                    ...data
                        .map((result) => _buildResultRow(context, result))
                        .toList(),
                  ],
                ),
              ],
            ),
          ),
      loading: () => const Center(child: ProgressCircle()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  TableRow _buildResultRow(BuildContext context, PingResult result) {
    return TableRow(
      children: [
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(result.hostname),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(result.ipAddr),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: SuccessRateBar(
              success: result.successCount,
              total: result.totalCount,
            ),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: PingStatusIndicator(lastPingFailed: result.lastPingFailed),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(result.minLatency.toStringAsFixed(1)),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(result.maxLatency.toStringAsFixed(1)),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(result.avgLatency.toStringAsFixed(1)),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(result.stdDevLatency.toStringAsFixed(1)),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: MacosIconButton(
              icon: const Icon(CupertinoIcons.chart_bar),
              onPressed: () {
                showMacosSheet(
                  context: context,
                  builder:
                      (context) => MacosSheet(
                        child: StatisticsCharts(host: result.hostname),
                      ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
