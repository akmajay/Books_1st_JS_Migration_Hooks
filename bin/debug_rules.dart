import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  final url = 'https://api.jayganga.com';
  final pb = PocketBase(url);
  
  print('--- Inspecting Users Collection Rules ---');
  
  try {
    // 1. Admin Auth
    await pb.admins.authWithPassword('life.jay.com@gmail.com', 'Akhilesh@2026');
    print('✅ Admin Auth Successful');

    // 2. Fetch Users Collection
    // We use the raw API because the SDK might not expose the collection config easily
    final res = await http.get(
      Uri.parse('$url/api/collections/users'),
      headers: {'Authorization': pb.authStore.token},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      print('\nCollection: ${data['name']}');
      print('List Rule:   ${data['listRule']}');
      print('View Rule:   ${data['viewRule']}');
      print('Create Rule: ${data['createRule']}');
      print('Update Rule: ${data['updateRule']}');
      print('Delete Rule: ${data['deleteRule']}');
      
      print('\nOAuth2 Enabled: ${data['oauth2']['enabled']}');
      if (data['oauth2']['providers'] != null) {
        print('Providers: ${(data['oauth2']['providers'] as List).map((e) => e['name']).toList()}');
      }
    } else {
      print('❌ Failed to fetch collection config: ${res.statusCode} ${res.body}');
    }

  } catch (e) {
    print('❌ Error: $e');
  }
}
