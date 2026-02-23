import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../services/auth_service.dart';
import '../../services/pocketbase_service.dart';
import '../../models/user_model.dart';
import '../../widgets/login_gate.dart';
import '../../services/seeding_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final PocketBase _pb = PocketBaseService.instance.pb;

  int _activeListings = 0;
  int _booksSold = 0;
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    if (_authService.isLoggedIn) {
      _loadStats();
    }
  }

  Future<void> _loadStats() async {
    final userId = _authService.currentUser?.id;
    if (userId == null) return;

    setState(() => _isLoadingStats = true);
    try {
      final activeResult = await _pb.collection('books').getList(
        page: 1,
        perPage: 1,
        filter: 'seller = "$userId" && status = "active"',
      );
      
      final soldResult = await _pb.collection('books').getList(
        page: 1,
        perPage: 1,
        filter: 'seller = "$userId" && status = "sold"',
      );

      if (mounted) {
        setState(() {
          _activeListings = activeResult.totalItems;
          _booksSold = soldResult.totalItems;
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading stats: $e');
      if (mounted) setState(() => _isLoadingStats = false);
    }
  }

  void _handleSignIn() async {
    final success = await LoginGate.show(context);
    if (success && mounted) {
      setState(() {}); // Rebuild to show logged-in view
      _loadStats();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_authService.isLoggedIn) {
      return _buildGuestView();
    }

    final user = _authService.currentUser!;
    final avatar = user.avatar ?? '';
    final avatarUrl = avatar.isNotEmpty 
        ? PocketBaseService.instance.getFileUrl(_pb.authStore.record as RecordModel, avatar) 
        : '';

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(user, avatarUrl),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildStatsRow(user),
                    const SizedBox(height: 32),
                    _buildMenu(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestView() {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.account_circle_outlined, size: 100, color: Colors.blue),
            const SizedBox(height: 24),
            Text(
              'Sign in to see your profile',
              style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Track your transactions, manage listings, and see your badges.',
              style: GoogleFonts.outfit(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _handleSignIn,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Sign In', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(UserModel user, String avatarUrl) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background Gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue, Color(0xFF1976D2)],
                ),
              ),
            ),
            // Header Content
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 42,
                          backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                          child: avatarUrl.isEmpty ? Text(user.name[0], style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)) : null,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/settings/profile-edit'),
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.edit, size: 14, color: Colors.blue[700]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.name,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    user.email,
                    style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(50),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Member since ${timeago.format(user.created, locale: 'en_short')}',
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(UserModel user) {
    return Row(
      children: [
        _buildStatBox('Active', _activeListings.toString(), Colors.blue),
        const SizedBox(width: 12),
        _buildStatBox('Sold', _booksSold.toString(), Colors.green),
        const SizedBox(width: 12),
        _buildStatBox('Trust', '${user.trustScore} ⭐', Colors.orange),
      ],
    );
  }

  Widget _buildStatBox(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Column(
          children: [
            if (_isLoadingStats && label != 'Trust')
              Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(width: 30, height: 20, color: Colors.white),
              )
            else
              Text(
                value,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color.withAlpha(255)),
              ),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenu() {
    return Column(
      children: [
        _buildMenuItem(Icons.library_books_outlined, 'My Listings', () => context.push('/manage-listings')),
        _buildMenuItem(Icons.receipt_long_outlined, 'My Transactions', () => context.push('/transactions')),
        _buildMenuItem(Icons.favorite_outline, 'My Wishlist', () => context.push('/wishlists')),
        _buildMenuItem(Icons.school_outlined, 'Academic Profile', () => _showAcademicEdit()),
        _buildMenuItem(Icons.emoji_events_outlined, 'My Badges', () => context.push('/badges')),
        _buildMenuItem(Icons.people_outline, 'Refer & Earn', () => context.push('/referral')),
        const Divider(height: 32),
        _buildMenuItem(Icons.settings_outlined, 'Settings', () => context.push('/settings')),
        const Divider(height: 32),
        _buildMenuItem(Icons.dataset_outlined, 'Seed Test Data', () => _handleSeedData()),
      ],
    );
  }

  Future<void> _handleSeedData() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seed Test Data?'),
        content: const Text('This will add sample books, schools, and banners to your account and the app for testing.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Seed Now')),
        ],
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seeding data...')));
      try {
        await SeedingService.instance.seedAll();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seeding complete! Refreshing...')));
          _loadStats();
        }
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error seeding: $e')));
      }
    }
  }

  Widget _buildMenuItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: Colors.blue[700]),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showAcademicEdit() {
    context.push('/settings/academic-profile');
  }
}
