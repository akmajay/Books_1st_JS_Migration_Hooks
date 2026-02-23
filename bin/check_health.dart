import 'package:pocketbase/pocketbase.dart';

void main() async {
  final pb = PocketBase('https://api.jayganga.com');
  
  print('--- DEFINITIVE BACKEND HEALTH CHECK ---');
  
  Future<void> test(String name, Future Function() fn) async {
    try {
      print('\nTesting: $name...');
      await fn();
      print('RESULT: ✅ SUCCESS');
    } catch (e) {
      print('RESULT: ❌ FAILED');
      print('ERROR: $e');
    }
  }

  await test('List Books (Base)', () async {
    final r = await pb.collection('books').getList(page: 1, perPage: 1);
    print('Found ${r.totalItems} books');
  });

  await test('List Books (Filter: status="active")', () async {
    final r = await pb.collection('books').getList(
      page: 1, 
      perPage: 1,
      filter: 'status = "active"',
    );
    print('Found ${r.totalItems} active books');
  });

  await test('List Books (Expand: seller,school)', () async {
    await pb.collection('books').getList(
      page: 1, 
      perPage: 1,
      expand: 'seller,school',
    );
  });

  await test('List Banners', () async {
    final r = await pb.collection('banners').getList(page: 1, perPage: 1);
    print('Found ${r.totalItems} banners');
  });

  await test('List Schools', () async {
    final r = await pb.collection('schools').getList(page: 1, perPage: 1);
    print('Found ${r.totalItems} schools');
  });

  print('\n--- CHECK COMPLETE ---');
}
