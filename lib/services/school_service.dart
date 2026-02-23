import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';
import '../models/school_model.dart';
import 'pocketbase_service.dart';

class SchoolService {
  static final SchoolService _instance = SchoolService._internal();
  factory SchoolService() => _instance;
  SchoolService._internal();

  PocketBase get _pb => PocketBaseService.instance.pb;

  /// Fetch all active schools
  Future<List<SchoolModel>> getActiveSchools({String? search}) async {
    try {
      final result = await _pb.collection('schools').getList(
        filter: 'is_active = true ${search != null ? '&& name ~ "$search"' : ''}',
        sort: 'name',
      );
      
      return result.items.map((record) => SchoolModel.fromJson(record.toJson())).toList();
    } catch (e) {
      debugPrint('Failed to fetch schools: $e');
      return [];
    }
  }

  /// Get school by ID
  Future<SchoolModel?> getSchoolById(String id) async {
    try {
      final record = await _pb.collection('schools').getOne(id);
      return SchoolModel.fromJson(record.toJson());
    } catch (e) {
      debugPrint('Failed to fetch school $id: $e');
      return null;
    }
  }
}
