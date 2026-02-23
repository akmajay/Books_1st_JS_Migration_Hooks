// ignore_for_file: avoid_print
import 'package:pocketbase/pocketbase.dart';

void main() async {
  final pb = PocketBase('https://api.jayganga.com');
  
  try {
    print('Fetching Auth Methods for users collection...');
    final dynamic authMethods = await pb.collection('users').listAuthMethods();
    
    print('\nAuth Methods keys:');
    // We can't easily list keys, but let's try common ones via dynamic
    try { print('  providers: ${authMethods.providers}'); } catch(_) {}
    try { print('  authProviders: ${authMethods.authProviders}'); } catch(_) {}
    try { print('  emailPassword: ${authMethods.emailPassword}'); } catch(_) {}
    try { print('  password: ${authMethods.password}'); } catch(_) {}
    try { print('  mfa: ${authMethods.mfa}'); } catch(_) {}
    try { print('  otp: ${authMethods.otp}'); } catch(_) {}
    
    print('\nRaw data (if available):');
    try { print(authMethods.toJson()); } catch(_) {}

  } catch (e) {
    print('ERROR: $e');
  }
}
