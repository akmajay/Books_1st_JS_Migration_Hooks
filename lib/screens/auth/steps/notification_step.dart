import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../services/auth_service.dart';

class NotificationStep extends StatefulWidget {
  final VoidCallback onContinue;

  const NotificationStep({
    super.key,
    required this.onContinue,
  });

  @override
  State<NotificationStep> createState() => _NotificationStepState();
}

class _NotificationStepState extends State<NotificationStep> {
  bool _isRequesting = false;

  Future<void> _requestPermission() async {
    setState(() => _isRequesting = true);
    
    try {
      final messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        await AuthService().registerFcmToken();
      }
      
      widget.onContinue();
    } catch (e) {
      debugPrint('Error requesting notifications: $e');
      widget.onContinue(); // Continue even if it fails
    } finally {
      if (mounted) setState(() => _isRequesting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.notifications_active_outlined,
            size: 64,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Stay updated',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Get notified about new messages, price drops, and book recommendations.',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            onPressed: _isRequesting ? null : _requestPermission,
            child: _isRequesting
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Enable Notifications', style: TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: widget.onContinue,
          child: const Text('Maybe Later'),
        ),
      ],
    );
  }
}
