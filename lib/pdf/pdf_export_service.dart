import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/ping_result.dart';
import 'pdf_report_builder.dart';

class PdfExportService {
  static Future<void> exportPingResults(List<PingResult> results) async {
    try {
      // Create and build the PDF using the default font
      final builder = PdfReportBuilder();
      await builder.buildReport(results);
      
      // Get directory for saving the file
      Directory saveDir;
      try {
        if (Platform.isMacOS) {
          // Use application documents directory (with write permissions)
          saveDir = await getApplicationDocumentsDirectory();
        } else {
          saveDir = await getApplicationDocumentsDirectory();
        }
      } catch (e) {
        // Use temporary directory as fallback if specific directory can't be accessed
        saveDir = await getTemporaryDirectory();
      }
      
      // Create timestamp-based filename
      final now = DateTime.now();
      final fileName = 'ping_results_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}.pdf';
      final file = File('${saveDir.path}/$fileName');
      
      // Save PDF file
      await file.writeAsBytes(await builder.document.save());
      
      // Open PDF file
      final result = await OpenFile.open(file.path);
      if (result.type != ResultType.done) {
        throw Exception('Failed to open file: ${result.message}');
      }
    } on pw.TooManyPagesException {
      // Handle exception caused by too many pages
      throw Exception('PDF generation failed: Too much data. Please reduce the number of ping results or limit the number of records per host.');
    } catch (e) {
      // Handle other exceptions
      throw Exception('PDF generation failed: $e');
    }
  }
}
