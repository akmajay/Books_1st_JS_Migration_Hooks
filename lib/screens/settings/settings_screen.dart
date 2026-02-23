import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/auth_service.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  String _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = 'v${info.version} (build ${info.buildNumber})';
    });
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('Are you sure you want to sign out of JayGanga Books?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.signOut();
      if (mounted) context.go('/');
    }
  }

  Future<void> _handleDeleteAccount() async {
    final confirm1 = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?', style: TextStyle(color: Colors.red)),
        content: const Text('This action is permanent and will delete all your listings, messages, and profile data.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Continue', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm1 != true) return;

    if (mounted) {
      final deleteText = await showDialog<String>(
        context: context,
        builder: (context) {
          final controller = TextEditingController();
          return AlertDialog(
            title: const Text('Confirm Deletion'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Please type "DELETE" to confirm your intent.'),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'DELETE'),
                  autofocus: true,
                  textCapitalization: TextCapitalization.characters,
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, controller.text),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                child: const Text('Verify & Delete'),
              ),
            ],
          );
        },
      );

      if (deleteText == 'DELETE') {
        // Implementation for account deletion via PB
        try {
          final userId = _authService.currentUser!.id;
          await _authService.pb.collection('users').delete(userId);
          await _authService.signOut();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Your account has been deleted.')));
            context.go('/');
          }
        } catch (e) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting account: $e')));
        }
      } else if (deleteText != null) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Confirmation text did not match.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          _buildSection('Account'),
          _buildTile(Icons.person_outline, 'Profile Edit', () => context.push('/settings/profile-edit')),
          _buildTile(Icons.block_outlined, 'Blocked Users', () => context.push('/settings/blocked-users')),
          
          _buildSection('Preferences'),
          _buildThemeTile(),
          _buildTile(Icons.notifications_outlined, 'Notifications', () => context.push('/settings/notifications')),
          _buildTile(Icons.location_on_outlined, 'Location Settings', () => context.push('/settings/profile-edit')),
          _buildTile(Icons.language, 'Language', null, subtitle: 'English (Coming Soon)', enabled: false),
          
          _buildSection('About'),
          _buildTile(Icons.description_outlined, 'Terms & Conditions', () => _launchUrl('https://jayganga.com/terms')),
          _buildTile(Icons.privacy_tip_outlined, 'Privacy Policy', () => _launchUrl('https://jayganga.com/privacy')),
          _buildTile(Icons.star_outline, 'Rate the App', () => _launchUrl('https://play.google.com/store/apps/details?id=com.jayganga.books')),
          _buildTile(Icons.info_outline, 'App Version', null, subtitle: _appVersion, showArrow: false),
          
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                OutlinedButton.icon(
                  onPressed: _handleLogout,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _handleDeleteAccount,
                  child: const Text('Delete Account', style: TextStyle(color: Colors.grey)),
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(color: Colors.blue[700], fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildTile(IconData icon, String title, VoidCallback? onTap, {String? subtitle, Widget? trailing, bool showArrow = true, bool enabled = true, Color? color}) {
    return ListTile(
      onTap: onTap,
      enabled: enabled,
      leading: Icon(icon, color: color ?? (enabled ? Colors.blue[700] : Colors.grey)),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: enabled ? null : Colors.grey)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: trailing ?? (showArrow && enabled ? const Icon(Icons.chevron_right, size: 20) : null),
    );
  }

  Widget _buildThemeTile() {
    final themeProvider = context.watch<ThemeProvider>();
    return ListTile(
      leading: const Icon(Icons.palette_outlined),
      title: const Text('Theme', style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(themeProvider.themeMode.name.toUpperCase()),
      trailing: DropdownButton<ThemeMode>(
        value: themeProvider.themeMode,
        underline: const SizedBox(),
        onChanged: (mode) {
          if (mode != null) themeProvider.setThemeMode(mode);
        },
        items: const [
          DropdownMenuItem(value: ThemeMode.system, child: Text('System 📱')),
          DropdownMenuItem(value: ThemeMode.light, child: Text('Light ☀️')),
          DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark 🌙')),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
