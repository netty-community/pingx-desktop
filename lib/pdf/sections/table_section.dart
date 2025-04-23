import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../models/ping_result.dart';

class PdfTableSection {
  final pw.Font font;

  PdfTableSection({required this.font});

  pw.Widget build(List<PingResult> results) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Summary Table',
          style: pw.TextStyle(
            font: font,
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 10),
        _buildSummaryTable(results),
      ],
    );
  }

  pw.Widget _buildSummaryTable(List<PingResult> results) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400),
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: PdfColors.grey200,
          ),
          children: [
            _buildTableCell('Host', header: true),
            _buildTableCell('IP Address', header: true),
            _buildTableCell('Success Rate', header: true),
            _buildTableCell('Min RTT', header: true),
            _buildTableCell('Avg RTT', header: true),
            _buildTableCell('Max RTT', header: true),
            _buildTableCell('Jitter', header: true),
          ],
        ),
        // Data rows
        ...results.map((result) => pw.TableRow(
          children: [
            _buildTableCell(result.hostname),
            _buildTableCell(result.ipAddr),
            _buildTableCell('${((result.successCount / result.totalCount) * 100).toStringAsFixed(1)}%'),
            _buildTableCell('${result.minLatency.toStringAsFixed(2)}ms'),
            _buildTableCell('${result.avgLatency.toStringAsFixed(2)}ms'),
            _buildTableCell('${result.maxLatency.toStringAsFixed(2)}ms'),
            _buildTableCell('${result.stdDevLatency.toStringAsFixed(2)}ms'),
          ],
        )),
      ],
    );
  }

  pw.Widget _buildTableCell(String text, {bool header = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      alignment: pw.Alignment.center,
      child: pw.Text(
        text,
        style: pw.TextStyle(
          font: font,
          fontSize: header ? 11 : 10,
          fontWeight: header ? pw.FontWeight.bold : null,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }
}
