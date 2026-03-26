import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

/// Compresses and resizes images before uploading to Supabase Storage.
///
/// Rules:
/// - Max dimension: 1080px (width or height)
/// - Quality: 70-80% JPEG
/// - Target: < 300 KB per image
class ImageCompressService {
  static const int _maxDimension = 1080;
  static const int _initialQuality = 80;
  static const int _minQuality = 50;
  static const int _targetSizeBytes = 300 * 1024; // 300 KB

  /// Pick an image from camera or gallery, then compress it.
  /// Returns the compressed image bytes and a suggested filename, or null if cancelled.
  static Future<CompressedImage?> pickAndCompress({
    required ImageSource source,
  }) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      // Initial resize via image_picker (fast, rough pass)
      maxWidth: _maxDimension.toDouble(),
      maxHeight: _maxDimension.toDouble(),
    );

    if (picked == null) return null;

    final bytes = await _compressFile(File(picked.path));
    if (bytes == null) return null;

    // Generate a filename with timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = 'item_${timestamp}.jpg';

    return CompressedImage(bytes: bytes, filename: filename);
  }

  /// Compress a file to meet the < 300 KB target.
  /// Uses progressive quality reduction if the first pass is still too large.
  static Future<Uint8List?> _compressFile(File file) async {
    int quality = _initialQuality;

    // First pass: resize + compress at 80% quality
    Uint8List? result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: _maxDimension,
      minHeight: _maxDimension,
      quality: quality,
      format: CompressFormat.jpeg,
      keepExif: false,
    );

    if (result == null) return null;

    // Progressive quality reduction until under target size
    while (result!.length > _targetSizeBytes && quality > _minQuality) {
      quality -= 10;
      result = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        minWidth: _maxDimension,
        minHeight: _maxDimension,
        quality: quality,
        format: CompressFormat.jpeg,
        keepExif: false,
      );
      if (result == null) return null;
    }

    return result;
  }
}

/// Holds compressed image data ready for upload.
class CompressedImage {
  final Uint8List bytes;
  final String filename;

  const CompressedImage({required this.bytes, required this.filename});

  /// Size in KB for display purposes.
  double get sizeKB => bytes.length / 1024;
}
