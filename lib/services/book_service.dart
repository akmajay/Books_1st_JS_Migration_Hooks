import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';
import 'pocketbase_service.dart';

class BookService {
  BookService._();
  static final BookService instance = BookService._();
  
  PocketBase get _pb => PocketBaseService.instance.pb;
  final String _collection = 'books';

  Future<ResultList<RecordModel>> getBooks({
    int page = 1,
    int perPage = 20,
    String? filter,
    String? sort,
    String? expand,
  }) {
    return _pb.collection(_collection).getList(
      page: page,
      perPage: perPage,
      filter: filter,
      sort: sort ?? '-created',
      expand: expand,
    );
  }

  Future<RecordModel> getBook(String id) {
    return _pb.collection(_collection).getOne(id, expand: 'seller,school');
  }

  Future<RecordModel> createBook(Map<String, dynamic> data, List<http.MultipartFile> files) {
    return _pb.collection(_collection).create(
      body: data,
      files: files,
    );
  }

  Future<RecordModel> updateBook(String id, {Map<String, dynamic>? body, List<http.MultipartFile>? files}) {
    return _pb.collection(_collection).update(
      id,
      body: body ?? {},
      files: files ?? [],
    );
  }

  Future<void> deleteBook(String id) {
    return _pb.collection(_collection).delete(id);
  }

  Future<ResultList<RecordModel>> searchBooks(String query, {int page = 1, int perPage = 20}) {
    final List<String> filterParts = [];
    // 0. Base Filter: only active books
    filterParts.add('status = "active"');

    // 1. Query
    if (query.isNotEmpty) {
      filterParts.add('(title ~ "$query" || author ~ "$query" || description ~ "$query")');
    }
    
    return getBooks(
      page: page,
      perPage: perPage,
      filter: filterParts.join(' && '),
      expand: 'seller,school',
    );
  }

  Future<ResultList<RecordModel>> getNearbyBooks(double lat, double lon, {double radiusKm = 5, int page = 1}) {
    return getBooks(
      page: page,
      perPage: 20,
      filter: 'status = "active"',
      expand: 'seller,school',
    );
  }
}

extension RecordModelGetExt on RecordModel {
  T get<T>(String key, {T? defaultValue}) {
    final val = data[key];
    if (val == null) return (defaultValue ?? (T == String ? '' : (T == double ? 0.0 : null))) as T;
    return val as T;
  }
}
