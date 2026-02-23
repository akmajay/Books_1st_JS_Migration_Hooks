import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/deep_link_service.dart';

class TermsStep extends StatefulWidget {
  final Map<String, dynamic> collectedData;
  final VoidCallback onComplete;

  const TermsStep({
    super.key,
    required this.collectedData,
    required this.onComplete,
  });

  @override
  State<TermsStep> createState() => _TermsStepState();
}

class _TermsStepState extends State<TermsStep> {
  bool _agreed = false;
  bool _isSubmitting = false;

  Future<void> _handleFinish() async {
    if (!_agreed) return;

    setState(() => _isSubmitting = true);
    
    try {
      final authService = context.read<AuthService>();
      final data = Map<String, dynamic>.from(widget.collectedData);
      data['onboarding_complete'] = true;
      
      final referralCode = DeepLinkService.instance.getPendingReferral();
      if (referralCode != null) {
        final referrerId = await authService.findUserIdByReferralCode(referralCode);
        if (referrerId != null) {
          data['referred_by'] = referrerId;
        }
      }

      await authService.updateProfile(data);
      
      if (referralCode != null) {
        await DeepLinkService.instance.clearPendingReferral();
      }
      
      widget.onComplete();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;
    final roleDisplay = _getRoleDisplay(widget.collectedData['user_type']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Almost done!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        _buildSummaryCard(user?.name ?? 'User', roleDisplay),
        const Spacer(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: _agreed,
              onChanged: (val) => setState(() => _agreed = val ?? false),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _agreed = !_agreed),
                child: const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text.rich(
                    TextSpan(
                      text: 'I agree to the ',
                      children: [
                        TextSpan(
                          text: 'Terms & Conditions',
                          style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                        ),
                        TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                        ),
                      ],
                    ),
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            onPressed: (_agreed && !_isSubmitting) ? _handleFinish : null,
            child: _isSubmitting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Get Started', style: TextStyle(fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String name, String role) {
    return Card(
      elevation: 0,
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _summaryRow(Icons.person_outline, 'Name', name),
            const Divider(height: 24),
            _summaryRow(Icons.location_on_outlined, 'Area', widget.collectedData['area'] ?? 'Not set'),
            const Divider(height: 24),
            _summaryRow(Icons.school_outlined, 'Profile', role),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[600]),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ],
    );
  }

  String _getRoleDisplay(String? type) {
    switch (type) {
      case 'school_student': return 'School Student';
      case 'college_student': return 'College Student';
      case 'exam_aspirant': return 'Exam Aspirant';
      default: return 'Not specified';
    }
  }
}
