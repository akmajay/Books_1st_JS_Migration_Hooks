import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';
import '../services/pocketbase_service.dart';
import '../services/auth_service.dart';

class SeedingService {
  static final SeedingService instance = SeedingService._();
  SeedingService._();

  final PocketBase _pb = PocketBaseService.instance.pb;

  Future<void> seedAll() async {
    if (!AuthService().isLoggedIn) throw 'You must be logged in to seed data.';
    final userId = AuthService().currentUser?.id;
    if (userId == null) throw 'User ID not found.';

    debugPrint('Starting Seeding...');

    // 1. Seed Schools (022 already does some, but let's ensure we have a fallback)
    final schoolResult = await _pb.collection('schools').getList(page: 1, perPage: 1);
    String schoolId = '';
    if (schoolResult.items.isEmpty) {
      final school = await _pb.collection('schools').create(body: {
        'name': 'Gyan Niketan',
        'type': 'school',
        'city': 'Patna',
      });
      schoolId = school.id;
    } else {
      schoolId = schoolResult.items.first.id;
    }

    // 2. Seed Banners
    final bannerResult = await _pb.collection('banners').getList(page: 1, perPage: 1);
    if (bannerResult.items.isEmpty) {
      await _pb.collection('banners').create(body: {
        'title': 'Welcome to JayGanga Books',
        'image_url': 'https://images.unsplash.com/photo-1512820790803-83ca734da794',
        'action_type': 'url',
        'action_value': 'https://jayganga.com',
        'is_active': true,
        'priority': 1,
      });
    }

    // 3. Seed Sample Books
    final bookCheck = await _pb.collection('books').getList(page: 1, perPage: 1, filter: 'seller = "$userId"');
    if (bookCheck.items.isEmpty) {
      final sampleBooks = [
        {
          'title': 'Concepts of Physics Vol 1',
          'author': 'H.C. Verma',
          'selling_price': 250,
          'mrp': 450,
          'category': 'jee_engineering',
          'condition': 'good',
          'board': 'CBSE',
          'class_year': '11',
          'status': 'active',
          'seller': userId,
          'school': schoolId,
          'description': 'A classic book for physics concepts.',
        },
        {
          'title': 'Mathematics for Class 10',
          'author': 'R.D. Sharma',
          'selling_price': 300,
          'mrp': 600,
          'category': 'school',
          'condition': 'like_new',
          'board': 'CBSE',
          'class_year': '10',
          'status': 'active',
          'seller': userId,
          'school': schoolId,
          'description': 'Comprehensive mathematics book.',
        }
      ];

      for (var book in sampleBooks) {
        await _pb.collection('books').create(body: book);
      }
    }
  }
}
