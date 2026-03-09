import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../domain/repositories/export_repository.dart';
import '../datasources/local_database.dart';

class ExportRepositoryImpl implements ExportRepository {
  final LocalDatabase _database;

  ExportRepositoryImpl(this._database);

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 텍스트 element에서 실제 텍스트 추출
  String _extractText(String content) {
    try {
      final data = jsonDecode(content) as Map<String, dynamic>;
      return data['text'] as String? ?? '';
    } catch (_) {
      return content;
    }
  }

  @override
  Future<String> exportAsZip({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (kIsWeb) throw UnsupportedError('웹에서는 내보내기를 지원하지 않습니다');

    final start = startDate ?? DateTime(2020, 1, 1);
    final end = endDate ?? DateTime.now();

    final startStr = _formatDate(start);
    final endStr = _formatDate(end);

    final pages = await _database.getPagesByDateRange(startStr, endStr);
    final archive = Archive();

    for (final page in pages) {
      final elements = await _database.getElementsByPageId(page.id);
      final dateParts = page.date.split('-');
      final year = dateParts[0];
      final month = dateParts[1];
      final day = dateParts[2];

      final pageData = {
        'id': page.id,
        'date': page.date,
        'background_type': page.backgroundType,
        'elements': elements.map((e) => e.toMap()).toList(),
      };

      final jsonBytes = utf8.encode(jsonEncode(pageData));
      archive.addFile(ArchiveFile(
        '$year/$month/$day.json',
        jsonBytes.length,
        jsonBytes,
      ));

      for (final element in elements) {
        if (element.type == 'image') {
          final imagePath = element.content;
          final imageFile = File(imagePath);
          if (await imageFile.exists()) {
            final imageBytes = await imageFile.readAsBytes();
            final fileName = imagePath.split('/').last;
            archive.addFile(ArchiveFile(
              '$year/$month/$fileName',
              imageBytes.length,
              imageBytes,
            ));
          }
        }
      }
    }

    final zipData = ZipEncoder().encode(archive);

    final outputDir = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${outputDir.path}/exports');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    final dateLabel = _formatDate(DateTime.now());
    final zipFile = File('${exportDir.path}/dakkoo_$dateLabel.zip');
    await zipFile.writeAsBytes(zipData);

    return zipFile.path;
  }

  @override
  Future<String> exportAsPdf({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (kIsWeb) throw UnsupportedError('웹에서는 내보내기를 지원하지 않습니다');

    final start = startDate ?? DateTime(2020, 1, 1);
    final end = endDate ?? DateTime.now();

    final startStr = _formatDate(start);
    final endStr = _formatDate(end);

    final pages = await _database.getPagesByDateRange(startStr, endStr);

    if (pages.isEmpty) {
      throw Exception('내보낼 일기가 없습니다');
    }

    final pdf = pw.Document();

    for (final page in pages) {
      final elements = await _database.getElementsByPageId(page.id);

      final dateParts = page.date.split('-');
      final dateDisplay =
          '${dateParts[0]}년 ${int.parse(dateParts[1])}월 ${int.parse(dateParts[2])}일';

      final textContents = elements
          .where((e) => e.type == 'text')
          .map((e) => _extractText(e.content))
          .where((t) => t.isNotEmpty)
          .toList();

      final stickers = elements
          .where((e) => e.type == 'sticker')
          .map((e) => e.content)
          .toList();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  dateDisplay,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Divider(thickness: 0.5),
                pw.SizedBox(height: 16),
                ...elements
                    .where((e) => e.type == 'image')
                    .map((e) {
                  final imageFile = File(e.content);
                  if (imageFile.existsSync()) {
                    try {
                      final imageBytes = imageFile.readAsBytesSync();
                      final image = pw.MemoryImage(imageBytes);
                      return pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 16),
                        child: pw.Center(
                          child: pw.Image(image, width: 300),
                        ),
                      );
                    } catch (_) {
                      return pw.SizedBox();
                    }
                  }
                  return pw.SizedBox();
                }),
                ...textContents.map((text) => pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 8),
                      child: pw.Text(
                        text,
                        style: const pw.TextStyle(
                          fontSize: 14,
                          lineSpacing: 6,
                        ),
                      ),
                    )),
                if (stickers.isNotEmpty) ...[
                  pw.SizedBox(height: 12),
                  pw.Wrap(
                    spacing: 8,
                    children: stickers
                        .map((s) => pw.Text(s,
                            style: const pw.TextStyle(fontSize: 20)))
                        .toList(),
                  ),
                ],
              ],
            );
          },
        ),
      );
    }

    final outputDir = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${outputDir.path}/exports');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    final dateLabel = _formatDate(DateTime.now());
    final pdfFile = File('${exportDir.path}/dakkoo_$dateLabel.pdf');
    await pdfFile.writeAsBytes(await pdf.save());

    return pdfFile.path;
  }
}
