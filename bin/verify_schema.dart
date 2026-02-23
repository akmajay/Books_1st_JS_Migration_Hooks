import 'package:pocketbase/pocketbase.dart';
import 'dart:convert';

void main() async {
  final pb = PocketBase('https://api.jayganga.com');

  try {
    print('Authenticating as superuser...');
    await pb.collection('_superusers').authWithPassword(
      'life.jay.com@gmail.com',
      'Akhilesh@2026',
    );
    print('Successfully authenticated.');

    print('Fetching users collection...');
    final col = await pb.collections.getOne('users');
    
    final fields = col.fields.map((f) => f.toJson()).toList();
    final hasSchool = fields.any((f) => f['name'] == 'school' && f['type'] == 'relation');
    final hasReferredBy = fields.any((f) => f['name'] == 'referred_by' && f['type'] == 'relation');

    print('\n--- Schema Results ---');
    print('school (relation): $hasSchool');
    print('referred_by (relation): $hasReferredBy');
    
    if (hasSchool && hasReferredBy) {
      print('\n✅ COMPLIANCE VERIFIED: All required relations are present.');
    } else {
      print('\n❌ COMPLIANCE FAILURE: Missing relations!');
    }
  } catch (e) {
    print('Error during verification: $e');
  }
}
