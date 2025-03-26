import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
          child: SelectableText(
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
          child: SelectableText(
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
        SelectableText(text),
      ],
    );
  }
}

class PingResultsTable extends ConsumerWidget {
  const PingResultsTable({super.key});

  Color _getRttColor(double rtt) {
    if (rtt < 150) {
      return CupertinoColors.systemGreen;
    } else if (rtt < 200) {
      return CupertinoColors.systemOrange;
    } else {
      return CupertinoColors.systemRed;
    }
  }

  Color _getJitterColor(double jitter) {
    if (jitter < 20) {
      return CupertinoColors.systemGreen;
    } else if (jitter < 50) {
      return CupertinoColors.systemYellow;
    } else {
      return CupertinoColors.systemRed;
    }
  }

  Widget _buildRttCell(BuildContext context, double rtt) {
    final color = _getRttColor(rtt);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        (rtt).toStringAsFixed(2),
        style: MacosTheme.of(
          context,
        ).typography.body.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildJitterCell(BuildContext context, double jitter) {
    final color = _getJitterColor(jitter);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        jitter.toStringAsFixed(2),
        style: MacosTheme.of(
          context,
        ).typography.body.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

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
                    0: FlexColumnWidth(1.1), // Hostname
                    1: FlexColumnWidth(0.9), // IP
                    2: FlexColumnWidth(1.8), // Success Rate
                    3: FlexColumnWidth(0.9), // Status
                    4: FlexColumnWidth(0.9), // Min
                    5: FlexColumnWidth(1.0), // Max
                    6: FlexColumnWidth(0.9), // Avg
                    7: FlexColumnWidth(0.9), // Jitter
                    8: FlexColumnWidth(0.7), // Actions
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: MacosTheme.of(
                          context,
                        ).primaryColor.withOpacity(0.1),
                      ),
                      children: [
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _buildSortableHeader(
                              context,
                              'Hostname',
                              'hostname',
                              ref,
                            ),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _buildSortableHeader(
                              context,
                              'IP Address',
                              'ipAddr',
                              ref,
                            ),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _buildSortableHeader(
                              context,
                              'Success Rate',
                              'successRate',
                              ref,
                            ),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _buildSortableHeader(
                              context,
                              'Last Status',
                              'lastStatus',
                              ref,
                            ),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _buildSortableHeader(
                              context,
                              'MinRTT(ms)',
                              'minLatency',
                              ref,
                            ),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _buildSortableHeader(
                              context,
                              'MaxRTT(ms)',
                              'maxLatency',
                              ref,
                            ),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _buildSortableHeader(
                              context,
                              'AvgRTT(ms)',
                              'avgLatency',
                              ref,
                            ),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _buildSortableHeader(
                              context,
                              'Jitter(ms)',
                              'jitter',
                              ref,
                            ),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SelectableText(
                              'Details',
                              textAlign: TextAlign.left,
                            ),
                          ),
                        ),
                      ],
                    ),
                    ...data
                        .map((result) => _buildResultRow(context, result, ref))
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

  Widget _buildSortableHeader(
    BuildContext context,
    String text,
    String field,
    WidgetRef ref,
  ) {
    final pingManager = ref.watch(pingManagerProvider);
    final isCurrentSort = pingManager.sortField == field;
    final theme = MacosTheme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          final manager = ref.read(pingManagerProvider);
          manager.setSortField(field);
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          decoration: BoxDecoration(
            color: isCurrentSort ? const Color(0xFFE8F3FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border:
                isCurrentSort
                    ? Border.all(color: const Color(0xFF007AFF), width: 1)
                    : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    SelectableText(
                      text,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color:
                            isCurrentSort
                                ? const Color(0xFF007AFF)
                                : theme.typography.headline.color,
                        fontWeight:
                            isCurrentSort ? FontWeight.w700 : FontWeight.w500,
                        fontSize: isCurrentSort ? 13.0 : null,
                      ),
                    ),
                    const SizedBox(width: 4),
                    if (isCurrentSort)
                      Icon(
                        pingManager.sortAscending
                            ? CupertinoIcons.arrow_up
                            : CupertinoIcons.arrow_down,
                        size: 14,
                        color: const Color(0xFF007AFF),
                      ),
                  ],
                ),
              ),
              if (!isCurrentSort)
                Icon(
                  CupertinoIcons.arrow_up_down,
                  size: 12,
                  color: const Color(0xFF666666),
                ),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _buildResultRow(
    BuildContext context,
    PingResult result,
    WidgetRef ref,
  ) {
    return TableRow(
      children: [
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SelectableText(result.hostname),
          ),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SelectableText(result.ipAddr),
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
          child: _buildRttCell(context, result.minLatency),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: _buildRttCell(context, result.maxLatency),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: _buildRttCell(context, result.avgLatency),
        ),
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: _buildJitterCell(context, result.stdDevLatency),
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
                        child: Consumer(
                          builder: (context, ref, _) {
                            // Get all results for this host
                            final results = ref.watch(pingResultsProvider);
                            final allResults = results.when(
                              data:
                                  (data) =>
                                      data
                                          .where(
                                            (r) =>
                                                r.hostname == result.hostname,
                                          )
                                          .toList(),
                              loading: () => [result],
                              error: (_, __) => [result],
                            );

                            return StatisticsCharts(
                              host: result.hostname,
                              hostResults: allResults,
                            );
                          },
                        ),
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
