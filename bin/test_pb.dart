// ignore_for_file: avoid_print
import 'package:pocketbase/pocketbase.dart';

void main() async {
  final pb = PocketBase('https://api.jayganga.com');
  
  try {
    print('Connecting to PocketBase...');
    await pb.collection('_superusers').authWithPassword(
      'life.jay.com@gmail.com',
      'Akhilesh@2026',
    );
    print('Admin Auth Successful');

    final collections = await pb.collections.getFullList();

    Future<void> updateRules(String name, {
      String? list, 
      String? view, 
      String? create, 
      String? update, 
      String? delete,
    }) async {
      try {
        final col = collections.firstWhere((c) => c.name == name);
        print('Updating $name...');
        
        // In 0.23.x, collection updates use the body map
        final body = <String, dynamic>{
          'listRule': list,
          'viewRule': view,
          'createRule': create,
          'updateRule': update,
          'deleteRule': delete,
        };
        
        // Only include non-null values to avoid overwriting rules we want to keep
        // Wait, if we want to CLEAR a rule, we must pass NULL. 
        // PocketBase interprets null as "no rule" (admin only).
        // If we want "Public", we pass "".
        
        await pb.collections.update(col.id, body: body);
      } catch (e) {
        print('Failed to update $name: $e');
      }
    }

    print('\nApplying Fixes (Prompt 4):');
    await updateRules('users', list: '', view: '', update: 'id = @request.auth.id');
    await updateRules('books', list: '', view: '', create: '@request.auth.id != ""', update: '@request.auth.id = seller.id', delete: '@request.auth.id = seller.id');
    await updateRules('schools', list: '', view: '');
    await updateRules('banners', list: '', view: '');
    await updateRules('advertisements', list: '', view: '');
    await updateRules('app_config', list: '', view: '');
    await updateRules('chats', list: '@request.auth.id != ""', view: '@request.auth.id != ""', create: '@request.auth.id != ""');
    await updateRules('messages', list: '@request.auth.id != ""', view: '@request.auth.id != ""', create: '@request.auth.id != ""');
    await updateRules('transactions', list: '@request.auth.id != ""', view: '@request.auth.id != ""', create: '@request.auth.id != ""');
    await updateRules('reviews', list: '', view: '', create: '@request.auth.id != ""');
    await updateRules('wishlists', list: '@request.auth.id = user.id', view: '@request.auth.id = user.id', create: '@request.auth.id != ""');
    await updateRules('reports', create: '@request.auth.id != ""');
    await updateRules('notifications', list: '@request.auth.id = user.id', view: '@request.auth.id = user.id');
    await updateRules('search_history', list: '@request.auth.id = user.id', create: '@request.auth.id != ""');
    await updateRules('referrals', list: '@request.auth.id != ""', create: ''); 
    await updateRules('blocked_users', list: '@request.auth.id = blocker.id', create: '@request.auth.id != ""');

    print('\nFinal Rule Check:');
    final freshCols = await pb.collections.getFullList();
    for (var col in freshCols) {
       if (!col.name.startsWith('_')) {
         print('${col.name.padRight(15)}: List="${col.listRule}", View="${col.viewRule}"');
       }
    }
    
    final health = await pb.health.check();
    print('\nAPI Status: ${health.code}');
  } catch (e) {
    print('CRITICAL ERROR: $e');
  }
}
