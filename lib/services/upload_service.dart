import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';
import 'image_service.dart';

class UploadService {
  final PocketBase pb;
  UploadService(this.pb);
  
  /// Upload single file to a record's file field
  Future<RecordModel> uploadFile({
    required String collectionName,
    required String recordId,
    required String fieldName,
    required File file,
    bool isAvatar = false,
  }) async {
    File compressed = isAvatar 
        ? await ImageService.compressAvatar(file) 
        : await ImageService.compress(file);
    
    try {
      return await pb.collection(collectionName).update(
        recordId,
        files: [
          http.MultipartFile.fromBytes(
            fieldName,
            await compressed.readAsBytes(),
            filename: compressed.path.split(Platform.pathSeparator).last,
          ),
        ],
      );
    } finally {
      // Clean up compressed temp file
      if (compressed.path != file.path) {
        await ImageService.cleanup(compressed);
      }
    }
  }
  
  /// Upload multiple files (e.g., book photos)
  Future<RecordModel> uploadMultipleFiles({
    required String collectionName,
    required String recordId,
    required String fieldName,
    required List<File> files,
    Function(int uploaded, int total)? onProgress,
  }) async {
    final multipartFiles = <http.MultipartFile>[];
    final compressedFiles = <File>[];
    
    try {
      for (int i = 0; i < files.length; i++) {
        final file = files[i];
        final compressed = await ImageService.compress(file);
        compressedFiles.add(compressed);
        
        multipartFiles.add(
          http.MultipartFile.fromBytes(
            fieldName,
            await compressed.readAsBytes(),
            filename: 'photo_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
          ),
        );
        onProgress?.call(i + 1, files.length);
      }
      
      return await pb.collection(collectionName).update(
        recordId,
        files: multipartFiles,
      );
    } finally {
      // Cleanup all temp files
      for (final f in compressedFiles) {
        await ImageService.cleanup(f);
      }
    }
  }
  
  /// Create record with files in one call
  Future<RecordModel> createWithFiles({
    required String collectionName,
    required Map<String, dynamic> body,
    required String fieldName,
    required List<File> files,
  }) async {
    final multipartFiles = <http.MultipartFile>[];
    final compressedFiles = <File>[];
    
    try {
      for (int i = 0; i < files.length; i++) {
        final compressed = await ImageService.compress(files[i]);
        compressedFiles.add(compressed);
        
        multipartFiles.add(
          http.MultipartFile.fromBytes(
            fieldName,
            await compressed.readAsBytes(),
            filename: 'photo_${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
          ),
        );
      }
      
      return await pb.collection(collectionName).create(
        body: body,
        files: multipartFiles,
      );
    } finally {
      for (final f in compressedFiles) {
        await ImageService.cleanup(f);
      }
    }
  }
  
  /// Delete a specific file from a record
  Future<RecordModel> deleteFile({
    required String collectionName,
    required String recordId,
    required String fieldName,
    required String fileName,
  }) async {
    return await pb.collection(collectionName).update(
      recordId,
      body: { '$fieldName-': fileName },
    );
  }
}
