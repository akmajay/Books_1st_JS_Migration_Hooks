import 'package:pocketbase/pocketbase.dart';

void main() async {
  final pb = PocketBase('https://api.jayganga.com');
  
  print('--- Detailed Filter Diagnostic ---');
  
  final fieldsToTest = ['status', 'title', 'author', 'category', 'seller', 'school'];
  
  for (final field in fieldsToTest) {
    try {
      print('\nTesting filter on: $field...');
      // Try a generic "not empty" or "is null" check to see if field exists
      final r = await pb.collection('books').getList(
        page: 1, 
        perPage: 1,
        filter: '$field != null',
      );
      print('SUCCESS: $field exists and filter worked. (Found ${r.totalItems} items)');
    } catch (e) {
      print('FAILED on $field: $e');
    }
  }

  try {
    print('\nTesting expand: seller...');
    await pb.collection('books').getList(page: 1, perPage: 1, expand: 'seller');
    print('SUCCESS: expand: seller worked');
  } catch (e) {
    print('FAILED on expand seller: $e');
  }

  try {
    print('\nTesting expand: school...');
    await pb.collection('books').getList(page: 1, perPage: 1, expand: 'school');
    print('SUCCESS: expand: school worked');
  } catch (e) {
    print('FAILED on expand school: $e');
  }
}
