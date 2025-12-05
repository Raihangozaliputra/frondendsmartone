import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageUtils {
  static final Uuid _uuid = Uuid();

  /// Compress an image file and return the compressed file
  static Future<File> compressImage(File imageFile, {int quality = 50}) async {
    final targetPath =
        '${(await getTemporaryDirectory()).path}/${_uuid.v4()}.jpg';

    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      imageFile.absolute.path,
      targetPath,
      quality: quality,
      minWidth: 1000,
      minHeight: 1000,
    );

    if (compressedFile == null) {
      throw Exception('Failed to compress image');
    }
    return File(compressedFile.path);
  }

  /// Compress image bytes and return compressed bytes
  static Future<Uint8List> compressImageBytes(
    Uint8List imageBytes, {
    int quality = 50,
  }) async {
    final compressedBytes = await FlutterImageCompress.compressWithList(
      imageBytes,
      quality: quality,
      minWidth: 1000,
      minHeight: 1000,
    );

    return compressedBytes;
  }

  /// Resize an image file and return the resized file
  static Future<File> resizeImage(
    File imageFile, {
    int maxWidth = 1000,
    int maxHeight = 1000,
  }) async {
    final targetPath =
        '${(await getTemporaryDirectory()).path}/${_uuid.v4()}.jpg';

    final resizedFile = await FlutterImageCompress.compressAndGetFile(
      imageFile.absolute.path,
      targetPath,
      minWidth: maxWidth > 1000 ? 1000 : maxWidth,
      minHeight: maxHeight > 1000 ? 1000 : maxHeight,
    );

    if (resizedFile == null) {
      throw Exception('Failed to resize image');
    }
    return File(resizedFile.path);
  }

  /// Get image dimensions
  static Future<ImageInfo> getImageInfo(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final image = await decodeImageFromList(bytes);
    return ImageInfo(width: image.width, height: image.height);
  }
  
  // Helper method to get image dimensions without Flutter context
  static Future<ui.Image> decodeImageFromList(Uint8List bytes) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(bytes, (ui.Image img) => completer.complete(img));
    return completer.future;
  }
}

class ImageInfo {
  final int width;
  final int height;

  ImageInfo({required this.width, required this.height});
}
