import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

/// Compresses and resizes images before uploading to Supabase Storage.
///
/// - Mobile: uses flutter_image_compress (JPEG, ≤300 KB, max 1080px)
/// - Web: relies on image_picker's built-in maxWidth/maxHeight downscale,
///   then uploads raw JPEG bytes directly (canvas compression not available).
class ImageCompressService {
  static const int _maxDimension = 1080;
  static const int _initialQuality = 80;
  static const int _minQuality = 50;
  static const int _targetSizeBytes = 300 * 1024; // 300 KB

  static Future<CompressedImage?> pickAndCompress({
    required ImageSource source,
  }) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: _maxDimension.toDouble(),
      maxHeight: _maxDimension.toDouble(),
      imageQuality: kIsWeb ? 80 : null, // web: let image_picker JPEG-encode
    );
    if (picked == null) return null;

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = 'item_$timestamp.jpg';

    if (kIsWeb) {
      // On web dart:io is unavailable; image_picker already downscaled + JPEG'd
      final bytes = await picked.readAsBytes();
      return CompressedImage(bytes: bytes, filename: filename);
    }

    // Mobile: progressive compression to stay under 300 KB
    final bytes = await picked.readAsBytes();
    final compressed = await _compressBytes(bytes);
    if (compressed == null) return null;
    return CompressedImage(bytes: compressed, filename: filename);
  }

  static Future<Uint8List?> _compressBytes(Uint8List input) async {
    int quality = _initialQuality;

    Uint8List? result = await FlutterImageCompress.compressWithList(
      input,
      minWidth: _maxDimension,
      minHeight: _maxDimension,
      quality: quality,
      format: CompressFormat.jpeg,
      keepExif: false,
    );
    if (result == null) return null;

    while (result!.length > _targetSizeBytes && quality > _minQuality) {
      quality -= 10;
      result = await FlutterImageCompress.compressWithList(
        input,
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

  double get sizeKB => bytes.length / 1024;
}
