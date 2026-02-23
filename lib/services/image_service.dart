import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ImageService {
  /// Compress image before upload
  /// Target: < 500 KB for book photos, < 200 KB for avatars
  static Future<File> compress(File file, {
    int maxWidth = 1200,
    int maxHeight = 1200,
    int quality = 80,
    int maxSizeKB = 500,
  }) async {
    final dir = await getTemporaryDirectory();
    final targetPath = p.join(dir.path, 'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');
    
    // First pass compression
    XFile? result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      minWidth: maxWidth,
      minHeight: maxHeight,
      quality: quality,
      format: CompressFormat.jpeg,
    );
    
    if (result == null) return file;
    
    // If still too large, reduce quality further
    File compressed = File(result.path);
    int sizeKB = await compressed.length() ~/ 1024;
    
    if (sizeKB > maxSizeKB) {
      int reducedQuality = (quality * maxSizeKB / sizeKB).clamp(20, 70).toInt();
      final retryPath = p.join(dir.path, 'retry_${DateTime.now().millisecondsSinceEpoch}.jpg');
      result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        retryPath,
        minWidth: maxWidth,
        minHeight: maxHeight,
        quality: reducedQuality,
        format: CompressFormat.jpeg,
      );
      if (result != null) {
        // Cleanup first attempt
        try { await compressed.delete(); } catch (_) {}
        compressed = File(result.path);
      }
    }
    
    return compressed;
  }
  
  /// Compress for avatar (smaller target)
  static Future<File> compressAvatar(File file) {
    return compress(file, maxWidth: 400, maxHeight: 400, maxSizeKB: 150);
  }
  
  /// Compress for chat image
  static Future<File> compressChatImage(File file) {
    return compress(file, maxWidth: 800, maxHeight: 800, maxSizeKB: 300);
  }
  
  /// Pick image from camera or gallery
  static Future<File?> pickImage({required ImageSource source}) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 90, // Initial quality hint
    );
    if (picked == null) return null;
    return File(picked.path);
  }
  
  /// Pick multiple images (for book listing)
  static Future<List<File>> pickMultipleImages({int maxCount = 5}) async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(
      imageQuality: 90,
      limit: maxCount,
    );
    return picked.map((xFile) => File(xFile.path)).toList();
  }

  /// Delete file safely
  static Future<void> cleanup(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Ignore cleanup errors
    }
  }
}
