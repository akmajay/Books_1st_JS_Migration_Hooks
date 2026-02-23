import 'package:pocketbase/pocketbase.dart';

void main() async {
  final pb = PocketBase('https://api.jayganga.com');
  
  print('--- Status Value Check ---');
  
  try {
    final result = await pb.collection('books').getList(page: 1, perPage: 1);
    
    if (result.items.isEmpty) {
      print('Database is empty.');
    } else {
      for (final book in result.items) {
        final status = book.getStringValue('status');
        print('Book ID: ${book.id} | Status: "$status"');
      }
    }
  } catch (e) {
    print('Check FAILED: $e');
  }
}
