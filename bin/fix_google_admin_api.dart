import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  final url = 'https://api.jayganga.com';
  final pb = PocketBase(url);
  
  print('--- Fix Google Client Secret via Admin API (Raw HTTP) ---');
  
  try {
    // 1. Admin Auth (Use environment variables for security)
    final adminEmail = String.fromEnvironment('PB_ADMIN_EMAIL');
    final adminPassword = String.fromEnvironment('PB_ADMIN_PASSWORD');
    await pb.admins.authWithPassword(adminEmail, adminPassword);
    print('✅ Admin Auth Successful');

    // 2. Prepare new config
    final newOptions = {
        "enabled": true,
        "providers": [
            {
                "name": "google",
                "clientId": String.fromEnvironment('GOOGLE_CLIENT_ID'),
                "clientSecret": String.fromEnvironment('GOOGLE_CLIENT_SECRET'),
                "displayName": "Google",
                "authUrl": "https://accounts.google.com/o/oauth2/auth",
                "tokenUrl": "https://accounts.google.com/o/oauth2/token",
            }
        ]
    };

    // 3. Update 'users' collection config
    final res = await http.patch(
      Uri.parse('$url/api/collections/users'),
      headers: {
        'Authorization': pb.authStore.token,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "oauth2": newOptions
      }),
    );

    if (res.statusCode == 200) {
      print('✅ Update Successful!');
    } else {
      print('❌ Update Failed: ${res.statusCode} ${res.body}');
    }

  } catch (e) {
    print('❌ Error: $e');
  }
}
