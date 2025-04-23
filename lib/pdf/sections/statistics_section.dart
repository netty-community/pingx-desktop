import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../models/ping_result.dart';

class PdfStatisticsSection {
  final pw.Font font;

  PdfStatisticsSection({required this.font});

  pw.Widget build(List<PingResult> results) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Detailed Statistics',
          style: pw.TextStyle(
            font: font,
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 20),
        ...results.map((result) => _buildHostStatistics(result)),
      ],
    );
  }

  pw.Widget _buildHostStatistics(PingResult result) {
    // Evaluate status color
    final statusColor = result.lastPingFailed ? PdfColors.red : PdfColors.green;
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            pw.Text(
              '${result.hostname} (${result.ipAddr})',
              style: pw.TextStyle(
                font: font,
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(width: 8),
            pw.Container(
              width: 12,
              height: 12,
              decoration: pw.BoxDecoration(
                color: statusColor,
                shape: pw.BoxShape.circle,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        _buildStatsGrid(result),
        pw.SizedBox(height: 20),
        pw.Divider(color: PdfColors.grey400),
        pw.SizedBox(height: 20),
      ],
    );
  }

  pw.Widget _buildStatsGrid(PingResult result) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      padding: const pw.EdgeInsets.all(8),
      child: pw.Table(
        columnWidths: {
          0: const pw.FlexColumnWidth(2),
          1: const pw.FlexColumnWidth(3),
          2: const pw.FlexColumnWidth(2),
          3: const pw.FlexColumnWidth(3),
          4: const pw.FlexColumnWidth(2),
          5: const pw.FlexColumnWidth(3),
        },
        children: [
          pw.TableRow(
            children: [
              _buildStatLabel('Total Packets'),
              _buildStatValue('${result.totalCount}'),
              _buildStatLabel('Successful'),
              _buildStatValue('${result.successCount}'),
              _buildStatLabel('Success Rate'),
              _buildStatValue(
                '${(result.successCount / (result.totalCount > 0 ? result.totalCount : 1) * 100).toStringAsFixed(2)}%',
                color: _getSuccessRateColor(result.successCount, result.totalCount),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              _buildStatLabel('Min RTT'),
              _buildStatValue('${result.minLatency.toStringAsFixed(2)}ms',
                color: _getRttColor(result.minLatency),
              ),
              _buildStatLabel('Avg RTT'),
              _buildStatValue('${result.avgLatency.toStringAsFixed(2)}ms',
                color: _getRttColor(result.avgLatency),
              ),
              _buildStatLabel('Max RTT'),
              _buildStatValue('${result.maxLatency.toStringAsFixed(2)}ms',
                color: _getRttColor(result.maxLatency),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              _buildStatLabel('Jitter'),
              _buildStatValue('${result.stdDevLatency.toStringAsFixed(2)}ms',
                color: _getJitterColor(result.stdDevLatency),
              ),
              _buildStatLabel('Failed'),
              _buildStatValue('${result.failureCount}',
                color: result.failureCount > 0 ? PdfColors.red : PdfColors.black,
              ),
              _buildStatLabel('Consecutive Fails'),
              _buildStatValue('${result.consecutiveFailureCount}',
                color: result.consecutiveFailureCount > 0 ? PdfColors.red : PdfColors.black,
              ),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildStatLabel(String label) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: pw.Text(
        label,
        style: pw.TextStyle(
          font: font,
          fontSize: 9,
          color: PdfColors.grey700,
        ),
      ),
    );
  }

  pw.Widget _buildStatValue(String value, {PdfColor? color}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      child: pw.Text(
        value,
        style: pw.TextStyle(
          font: font,
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
  
  // RTT color based on response time
  PdfColor _getRttColor(double rtt) {
    if (rtt < 150) {
      return PdfColors.green;
    } else if (rtt < 200) {
      return PdfColors.orange;
    } else {
      return PdfColors.red;
    }
  }
  
  // Jitter color based on stability
  PdfColor _getJitterColor(double jitter) {
    if (jitter < 20) {
      return PdfColors.green;
    } else if (jitter < 50) {
      return PdfColors.orange;
    } else {
      return PdfColors.red;
    }
  }
  
  // Success rate color
  PdfColor _getSuccessRateColor(int success, int total) {
    if (total == 0) return PdfColors.black;
    
    final rate = success / total * 100;
    if (rate > 95) {
      return PdfColors.green;
    } else if (rate > 80) {
      return PdfColors.orange;
    } else {
      return PdfColors.red;
    }
  }
}
