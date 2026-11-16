import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/uv_data.dart';

class CsvExportService {
  /// Mengonversi daftar UvData menjadi format teks CSV
  static String generateCsvString(List<UvData> dataList, {String channelId = 'Unknown'}) {
    final buffer = StringBuffer();

    // Metadata Header
    buffer.writeln('# UV Monitor App - ThingSpeak Export');
    buffer.writeln('# Channel ID: $channelId');
    buffer.writeln('# Tanggal Ekspor: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}');
    buffer.writeln('# Total Baris Data: ${dataList.length}');
    buffer.writeln('');

    // Column Headers
    buffer.writeln('Entry ID,Tanggal & Waktu Lokal,Waktu UTC,Indeks UV,Kategori Risiko,Status,Saran Utama');

    // Data Rows
    for (final item in dataList) {
      final entryId = item.entryId?.toString() ?? '-';
      final localTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(item.timestamp);
      final utcTime = item.timestamp.toUtc().toIso8601String();
      final uv = item.uvIndex.toStringAsFixed(1);
      final category = item.riskLevel.label;
      final status = item.riskLevel.localizedName;
      // Ambil saran pertama dan bersihkan dari koma agar tidak merusak CSV
      final cleanTip = item.riskLevel.tips.isNotEmpty
          ? '"${item.riskLevel.tips.first.replaceAll('"', '""')}"'
          : '""';

      buffer.writeln('$entryId,$localTime,$utcTime,$uv,$category,$status,$cleanTip');
    }

    return buffer.toString();
  }

  /// Membuat file CSV dan membuka sheet download / bagikan file
  static Future<File> exportAndShareCsv(
    List<UvData> dataList, {
    String channelId = 'ThingSpeak',
  }) async {
    if (dataList.isEmpty) {
      throw Exception('Tidak ada data UV untuk diekspor.');
    }

    final csvContent = generateCsvString(dataList, channelId: channelId);

    // Dapatkan direktori sementara
    final directory = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = 'uv_data_${channelId}_$timestamp.csv';
    final filePath = '${directory.path}/$fileName';

    final file = File(filePath);
    await file.writeAsString(csvContent, flush: true);

    // Buka share sheet agar pengguna bisa langsung menyimpannya ke folder Downloads,
    // Google Drive, WhatsApp, atau aplikasi spreadsheet (Excel, Sheets).
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(filePath, mimeType: 'text/csv', name: fileName)],
        subject: 'Data Ekspor Indeks UV - $channelId',
        text: 'Berikut adalah data riwayat indeks UV dari ThingSpeak ($fileName).',
      ),
    );

    return file;
  }
}
