import 'package:pocketbase/pocketbase.dart';

class ImageUrlHelper {
  static const String _baseUrl = 'https://api.jayganga.com'; // PB Base URL
  
  /// Get full image URL from PocketBase record
  static String getUrl(RecordModel record, String fileName) {
    return '$_baseUrl/api/files/${record.collectionId}/${record.id}/$fileName';
  }
  
  /// Get thumbnail URL (PocketBase built-in thumb generation)
  /// Sizes: "100x100", "200x200", "300x300", etc.
  static String getThumbUrl(RecordModel record, String fileName, {
    String size = '200x200',
  }) {
    if (fileName.isEmpty) return '';
    return '$_baseUrl/api/files/${record.collectionId}/${record.id}/$fileName?thumb=$size';
  }
  
  /// Get first photo URL from a book record
  static String? getBookCover(RecordModel book) {
    final photos = book.getListValue<String>('photos');
    if (photos.isEmpty) return null;
    return getThumbUrl(book, photos.first, size: '400x400');
  }
  
  /// Get all photo URLs for a book
  static List<String> getBookPhotos(RecordModel book, {bool fullSize = false}) {
    final photos = book.getListValue<String>('photos');
    return photos.map((p) => fullSize
      ? getUrl(book, p)
      : getThumbUrl(book, p, size: '800x800')
    ).toList();
  }
  
  /// Get user avatar URL
  static String? getAvatar(RecordModel user, {String size = '200x200'}) {
    final avatar = user.getStringValue('avatar');
    if (avatar.isEmpty) return null;
    return getThumbUrl(user, avatar, size: size);
  }
}
