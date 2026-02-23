import 'package:pocketbase/pocketbase.dart';

void main() async {
  final pb = PocketBase('https://api.jayganga.com');
  
  print('--- Debugging PocketBase API ---');
  
  try {
    print('1. Testing simple list (no filter, no expand)...');
    final r1 = await pb.collection('books').getList(page: 1, perPage: 1);
    print('SUCCESS: Found ${r1.totalItems} books');
  } catch (e) {
    print('FAILED: $e');
  }

  try {
    print('\n2. Testing filter (status = "active")...');
    final r2 = await pb.collection('books').getList(
      page: 1, 
      perPage: 1,
      filter: 'status = "active"',
    );
    print('SUCCESS: Found ${r2.totalItems} active books');
  } catch (e) {
    print('FAILED: $e');
  }

  try {
    print('\n3. Testing expand (seller,school)...');
    final r3 = await pb.collection('books').getList(
      page: 1, 
      perPage: 1,
      expand: 'seller,school',
    );
    print('SUCCESS: Expand worked');
  } catch (e) {
    print('FAILED: $e');
  }

  try {
    print('\n4. Testing sort (-created)...');
    final r4 = await pb.collection('books').getList(
      page: 1, 
      perPage: 1,
      sort: '-created',
    );
    print('SUCCESS: Sort worked');
  } catch (e) {
    print('FAILED: $e');
  }
}
