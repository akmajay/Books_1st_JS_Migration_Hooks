// ignore_for_file: avoid_print
import 'package:pocketbase/pocketbase.dart';

void main() async {
  final pb = PocketBase('https://api.jayganga.com');
  
  try {
    print('Fetching Auth Methods for users collection...');
    final authMethods = await pb.collection('users').listAuthMethods();
    
    print('\nAuth Methods:');
    print('  Password Enabled: ${authMethods.password.enabled}');
    print('  OAuth2 Providers:');
    // Using a more robust check for different PB client versions
    final providers = (authMethods as dynamic).authProviders;
    if (providers == null || (providers as List).isEmpty) {
      print('    NONE configured!');
    } else {
      for (var p in providers) {
        print('    - Name: ${p.name}');
        print('      DisplayName: ${p.displayName}');
      }
    }
  } catch (e) {
    print('ERROR: $e');
  }
}
