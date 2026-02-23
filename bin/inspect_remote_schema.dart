import 'package:pocketbase/pocketbase.dart';

void main() async {
  final pb = PocketBase('https://api.jayganga.com');
  
  print('--- Inspecting Remote Schema ---');
  
  try {
    // We can't easily list collections without admin auth, 
    // but we can try to fetch one record and see the available fields
    final result = await pb.collection('books').getList(page: 1, perPage: 1);
    
    if (result.items.isEmpty) {
      print('No books found. Creating a temporary test book to see fields...');
      // This will likely fail if we are not logged in, but let's see.
    } else {
      final book = result.items.first;
      print('Fields in books record: ${book.data.keys.toList()}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
