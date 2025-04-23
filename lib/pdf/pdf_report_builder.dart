import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/ping_result.dart';
import 'sections/table_section.dart';
import 'sections/statistics_section.dart';

class PdfReportBuilder {
  final pw.Document document;
  final pw.Font font;
  
  // Constants to control PDF size and avoid TooManyPagesException
  static const int MaxItemsPerPage = 10;
  static const int MaxItemsPerDocument = 100;

  PdfReportBuilder({pw.Font? font}) 
    : document = pw.Document(),
      font = font ?? pw.Font.helvetica();

  Future<void> buildReport(List<PingResult> results) async {
    // First page with summary table for all results
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        maxPages: 10, // Limit to avoid exceptions
        build: (context) => [
          _buildHeader(),
          pw.SizedBox(height: 20),
          PdfTableSection(font: font).build(results),
        ],
        footer: _buildFooter,
      ),
    );
    
    // Add separate pages for detailed statistics in batches
    // to avoid TooManyPagesException
    final int totalHosts = results.length;
    final int totalPages = (totalHosts / MaxItemsPerPage).ceil();
    final int actualPages = totalPages > 10 ? 10 : totalPages;
    
    for (int i = 0; i < actualPages; i++) {
      final int startIndex = i * MaxItemsPerPage;
      final int endIndex = (startIndex + MaxItemsPerPage < totalHosts) 
          ? startIndex + MaxItemsPerPage 
          : totalHosts;
      
      final batch = results.sublist(startIndex, endIndex);
      
      document.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          maxPages: 10, // Limit to avoid exceptions
          build: (context) => [
            pw.Header(
              level: 1,
              child: pw.Text(
                'Detailed Statistics (Page ${i + 1}/${actualPages})',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            PdfStatisticsSection(font: font).build(batch),
          ],
          footer: _buildFooter,
        ),
      );
    }
  }

  pw.Widget _buildHeader() {
    return pw.Container(
      alignment: pw.Alignment.center,
      child: pw.Column(
        children: [
          pw.Text(
            'Ping Results Report',
            style: pw.TextStyle(
              font: font,
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Generated on ${DateTime.now().toString().substring(0, 19)}',
            style: pw.TextStyle(
              font: font,
              fontSize: 14,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
  
  pw.Widget _buildFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      margin: const pw.EdgeInsets.only(top: 10),
      child: pw.Text(
        'Page ${context.pageNumber} of ${context.pagesCount}',
        style: pw.TextStyle(
          font: font,
          fontSize: 10,
        ),
      ),
    );
  }
}
