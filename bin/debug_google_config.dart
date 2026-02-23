import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  final url = 'https://api.jayganga.com';
  final pb = PocketBase(url);
  
  print('--- Inspecting Google Settings ---');
  
  try {
    // 1. Admin Auth
    await pb.admins.authWithPassword('life.jay.com@gmail.com', 'Akhilesh@2026');

    // 2. Fetch Users Collection
    final res = await http.get(
      Uri.parse('$url/api/collections/users'),
      headers: {'Authorization': pb.authStore.token},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final oauth = data['oauth2'] as Map<String, dynamic>;
      final providers = (oauth['providers'] as List).cast<Map<String, dynamic>>();
      
      final google = providers.firstWhere((p) => p['name'] == 'google', orElse: () => {});
      
      if (google.isNotEmpty) {
        print('Google Provider Found:');
        print('  Client ID: ${google['clientId']}');
        // We only print the first few chars of secret to verify existence without leaking full secret if logs are shared inappropriately
        final secret = google['clientSecret'] as String?;
        if (secret == null || secret.isEmpty) {
          print('  Client Secret: [MISSING/EMPTY] ❌');
        } else {
          print('  Client Secret: ${secret.substring(0, 5)}... (Length: ${secret.length}) ✅');
        }
        print('  Auth URL: ${google['authUrl']}');
        print('  Token URL: ${google['tokenUrl']}');
      } else {
        print('Google Provider NOT FOUND ❌');
      }
      
    } else {
      print('Failed: ${res.statusCode}');
    }

  } catch (e) {
    print('Error: $e');
  }
}
