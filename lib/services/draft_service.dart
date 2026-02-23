import 'package:hive_flutter/hive_flutter.dart';

class DraftService {
  static const String _boxName = 'sell_draft';

  /// Save the current form state to Hive
  static Future<void> saveDraft(Map<String, dynamic> data) async {
    final box = Hive.box(_boxName);
    await box.put('listing', data);
  }

  /// Retrieve the saved draft if it exists
  static Map<String, dynamic>? getDraft() {
    final box = Hive.box(_boxName);
    final data = box.get('listing');
    if (data == null) return null;
    return Map<String, dynamic>.from(data);
  }

  /// Discard the current draft (e.g., after successful publish)
  static Future<void> clearDraft() async {
    final box = Hive.box(_boxName);
    await box.delete('listing');
  }

  /// Check if a draft exists
  static bool hasDraft() {
    final box = Hive.box(_boxName);
    return box.containsKey('listing');
  }
}
