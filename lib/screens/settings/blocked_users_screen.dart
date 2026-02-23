import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import '../../services/auth_service.dart';
import '../../services/pocketbase_service.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  final PocketBase _pb = PocketBaseService.instance.pb;
  final AuthService _authService = AuthService();
  
  List<RecordModel> _blockedItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBlockedUsers();
  }

  Future<void> _loadBlockedUsers() async {
    final userId = _authService.currentUser?.id;
    if (userId == null) return;

    setState(() => _isLoading = true);
    try {
      final result = await _pb.collection('blocked_users').getList(
        filter: 'blocker = "$userId"',
        expand: 'blocked',
      );
      if (mounted) {
        setState(() {
          _blockedItems = result.items;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _unblock(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unblock User?'),
        content: const Text('They will be able to message you and see your listings again.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Unblock')),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _pb.collection('blocked_users').delete(id);
      setState(() {
        _blockedItems.removeWhere((item) => item.id == id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User unblocked')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Blocked Users')),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _blockedItems.isEmpty 
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _blockedItems.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = _blockedItems[index];
                    final blockedUser = item.get<List<RecordModel>>('expand.blocked').first;
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(blockedUser.getStringValue('name')[0].toUpperCase()),
                      ),
                      title: Text(blockedUser.getStringValue('name')),
                      trailing: TextButton(
                        onPressed: () => _unblock(item.id),
                        child: const Text('Unblock', style: TextStyle(color: Colors.red)),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text('You haven\'t blocked anyone.', style: TextStyle(color: Colors.grey)),
    );
  }
}
