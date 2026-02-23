import 'package:pocketbase/pocketbase.dart';

void main() async {
  final pb = PocketBase('https://api.jayganga.com');

  try {
    print('Fetching schools...');
    final result = await pb.collection('schools').getList(perPage: 50);
    print('Total schools found: ${result.totalItems}');
    for (var item in result.items) {
      print(' - [${item.id}] ${item.getStringValue("name")} (${item.getStringValue("city")})');
    }
  } catch (e) {
    print('Error: $e');
  }
}
