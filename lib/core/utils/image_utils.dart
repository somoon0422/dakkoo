import 'dart:io';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';

class ImageUtils {
  ImageUtils._();

  static Future<String> getImageDirectory(DateTime date) async {
    final appDir = await getApplicationDocumentsDirectory();
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final dir = Directory('${appDir.path}/images/$year/$month');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  static Future<String> getThumbnailDirectory(DateTime date) async {
    final appDir = await getApplicationDocumentsDirectory();
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final dir = Directory('${appDir.path}/thumbnails/$year/$month');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  static Future<File> compressAndSaveImage(
    File sourceFile,
    DateTime date,
    String fileName,
  ) async {
    final dir = await getImageDirectory(date);
    final targetPath = '$dir/$fileName';

    final bytes = await sourceFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: 1024,
    );
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    image.dispose();

    if (byteData != null) {
      final compressedBytes = byteData.buffer.asUint8List();
      final file = File(targetPath);
      await file.writeAsBytes(compressedBytes);
      return file;
    }

    return sourceFile.copy(targetPath);
  }

  static Future<File> createThumbnail(
    File sourceFile,
    DateTime date,
    String fileName,
  ) async {
    final dir = await getThumbnailDirectory(date);
    final targetPath = '$dir/$fileName';

    final bytes = await sourceFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: 200,
    );
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    image.dispose();

    if (byteData != null) {
      final compressedBytes = byteData.buffer.asUint8List();
      final file = File(targetPath);
      await file.writeAsBytes(compressedBytes);
      return file;
    }

    return sourceFile.copy(targetPath);
  }
}
