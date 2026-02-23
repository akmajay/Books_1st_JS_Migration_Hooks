import 'package:pocketbase/pocketbase.dart';

void main() async {
  final pb = PocketBase('https://api.jayganga.com');
  
  print('--- Final Data Inspection ---');
  
  try {
    final result = await pb.collection('books').getList(
      page: 1, 
      perPage: 1,
      expand: 'seller,school',
    );
    
    if (result.items.isEmpty) {
      print('Database is empty.');
    } else {
      final book = result.items.first;
      print('ID: ${book.id}');
      print('Data keys: ${book.data.keys.toList()}');
      print('Full Data: ${book.data}');
      print('Expand Data: ${book.expand}');
    }
  } catch (e) {
    print('Inspection FAILED: $e');
  }
}
