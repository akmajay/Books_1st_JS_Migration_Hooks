import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../services/pocketbase_service.dart';
import '../../config/deeplink_config.dart';
import 'package:pocketbase/pocketbase.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  final _pb = PocketBaseService.instance.pb;
  final _auth = AuthService();
  
  List<RecordModel> _referrals = [];
  bool _isLoading = true;
  int _successfulCount = 0;

  @override
  void initState() {
    super.initState();
    _loadReferralData();
  }

  Future<void> _loadReferralData() async {
    try {
      final result = await _pb.collection('referrals').getList(
        filter: 'referrer = "${_auth.currentUser?.id}"',
        expand: 'referred_user',
        sort: '-created',
      );
      
      setState(() {
        _referrals = result.items;
        _successfulCount = _referrals.where((r) => r.getStringValue('status') == 'active' || r.getStringValue('status') == 'completed').length;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading referrals: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _shareReferralLink() {
    final code = _auth.currentUser?.referralCode ?? '';
    if (code.isEmpty) return;
    
    final link = DeepLinkConfig.referralUrl(code);
    SharePlus.share(
      'Hey! I\'m using JayGanga Books to buy & sell used books near me. Join using my link and we both get rewards! 📚\n\n$link',
      subject: 'Invite to JayGanga Books',
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final referralCode = user?.referralCode ?? '------';

    return Scaffold(
      appBar: AppBar(
        title: Text('Refer & Earn', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
      ),
      body: RefreshIndicator(
        onRefresh: _loadReferralData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Illustration & Header
              const Icon(Icons.group_add_outlined, size: 80, color: Colors.deepOrange),
              const SizedBox(height: 16),
              Text(
                'Invite Friends & Earn Rewards!',
                style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Help your friends find affordable books and earn exclusive badges and perks together.',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Code Box
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withAlpha(10),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.deepOrange.withAlpha(30)),
                ),
                child: Column(
                  children: [
                    const Text('YOUR REFERRAL CODE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.deepOrange)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          referralCode,
                          style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 4),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: referralCode));
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code copied!')));
                          },
                          icon: const Icon(Icons.copy, size: 20, color: Colors.deepOrange),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _shareReferralLink,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.share),
                      label: const Text('Share Invite Link', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Stats Row
              Row(
                children: [
                  _buildStatCard('Total Invites', _referrals.length.toString(), Icons.people_outline),
                  const SizedBox(width: 16),
                  _buildStatCard('Successful', _successfulCount.toString(), Icons.check_circle_outline),
                ],
              ),

              const SizedBox(height: 40),

              // Referral List
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Recent Referrals', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_referrals.isEmpty)
                _buildEmptyState()
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _referrals.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final ref = _referrals[index];
                    final referredUserList = ref.get<List<RecordModel>>('expand.referred_user');
                    if (referredUserList.isEmpty) return const SizedBox.shrink();
                    final referredUser = referredUserList.first;

                    final status = ref.getStringValue('status');
                    final date = DateTime.tryParse(ref.getStringValue('created')) ?? DateTime.now();

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        backgroundImage: referredUser.getStringValue('avatar').isNotEmpty 
                            ? NetworkImage('${PocketBaseService.instance.pb.baseURL}/api/files/users/${referredUser.id}/${referredUser.getStringValue('avatar')}')
                            : null,
                        child: referredUser.getStringValue('avatar').isEmpty ? const Icon(Icons.person, color: Colors.grey) : null,
                      ),
                      title: Text(referredUser.getStringValue('name'), style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Joined ${date.day}/${date.month}/${date.year}'),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withAlpha(20),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(color: _getStatusColor(status), fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
                
              const SizedBox(height: 40),
              
              // How it works
              _buildHowItWorks(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.deepOrange, size: 24),
            const SizedBox(height: 12),
            Text(value, style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildHowItWorks() {
    return Column(
      children: [
        Text('How It Works', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        _buildHowStep('1', 'Share your link', 'Send your unique invite link to friends who enjoy reading.'),
        _buildHowStep('2', 'Friend signs up', 'When they join JayGanga Books using your link, we track it.'),
        _buildHowStep('3', 'Earn Rewards', 'Once they complete their first trade, you both get exclusive badges!'),
      ],
    );
  }

  Widget _buildHowStep(String number, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(color: Colors.deepOrange, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(desc, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.people_outline, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No referrals yet. Start inviting friends to see them here!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'joined': return Colors.blue;
      case 'active': return Colors.green;
      case 'completed': return Colors.purple;
      default: return Colors.grey;
    }
  }
}
