import 'package:flutter/material.dart';
import '../../services/pocketbase_service.dart';
import '../../services/auth_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final _pb = PocketBaseService.instance.pb;
  final _auth = AuthService();
  
  Map<String, dynamic> _prefs = {
    'new_message': true,
    'new_offer': true,
    'transactions': true,
    'price_drop': true,
    'new_review': true,
    'promotions': false,
  };

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final userPrefs = _auth.currentUser?.notificationPreferences;
    if (userPrefs != null) {
      _prefs = Map<String, dynamic>.from(userPrefs);
    }
  }

  Future<void> _togglePref(String key, bool value) async {
    setState(() {
      _prefs[key] = value;
      _isSaving = true;
    });

    try {
      await _pb.collection('users').update(_auth.currentUser!.id, body: {
        'notification_preferences': _prefs,
      });
      await _auth.refreshUser();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        bottom: _isSaving ? const PreferredSize(
          preferredSize: Size.fromHeight(2),
          child: LinearProgressIndicator(minHeight: 2),
        ) : null,
      ),
      body: ListView(
        children: [
          _buildToggle('Messages', 'New chat messages', 'new_message'),
          _buildToggle('Offers', 'New price offers', 'new_offer'),
          _buildToggle('Transactions', 'Transaction status updates', 'transactions'),
          _buildToggle('Price Drops', 'Wishlisted book price changes', 'price_drop'),
          _buildToggle('Reviews', 'New reviews received', 'new_review'),
          _buildToggle('Promotions', 'App tips and announcements', 'promotions'),
        ],
      ),
    );
  }

  Widget _buildToggle(String title, String subtitle, String key) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      value: _prefs[key] ?? true,
      onChanged: _isSaving ? null : (val) => _togglePref(key, val),
    );
  }
}
