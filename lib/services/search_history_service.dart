import 'package:hive_flutter/hive_flutter.dart';

class SearchHistoryService {
  static const String _boxName = 'search_history';

  static Future<void> init() async {
    await Hive.openBox<String>(_boxName);
  }

  static List<String> getHistory() {
    final box = Hive.box<String>(_boxName);
    return box.values.toList().reversed.toList();
  }

  static Future<void> addQuery(String query) async {
    if (query.trim().isEmpty) return;
    
    final box = Hive.box<String>(_boxName);
    final history = box.values.toList();
    
    // Remove if already exists (to move to top)
    history.removeWhere((item) => item.toLowerCase() == query.toLowerCase().trim());
    
    // Add new query
    history.add(query.trim());
    
    // Limit to 10
    if (history.length > 10) {
      history.removeAt(0);
    }
    
    await box.clear();
    await box.addAll(history);
  }

  static Future<void> removeQuery(String query) async {
    final box = Hive.box<String>(_boxName);
    final history = box.values.toList();
    history.removeWhere((item) => item.toLowerCase() == query.toLowerCase().trim());
    
    await box.clear();
    await box.addAll(history);
  }

  static Future<void> clearHistory() async {
    final box = Hive.box<String>(_boxName);
    await box.clear();
  }
}
