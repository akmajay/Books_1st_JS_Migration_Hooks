import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/forms/app_phone_field.dart';

class MobileNumberStep extends StatefulWidget {
  final Function(String) onSaved;
  final String? initialValue;

  const MobileNumberStep({
    super.key,
    required this.onSaved,
    this.initialValue,
  });

  @override
  State<MobileNumberStep> createState() => _MobileNumberStepState();
}

class _MobileNumberStepState extends State<MobileNumberStep> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isValid = false;
  bool _isChecking = false;
  String? _serverError;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!.replaceFirst('+91', '');
      _checkValidity(_controller.text);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkValidity(String value) {
    setState(() {
      _isValid = value.length == 10;
      _serverError = null;
    });
  }

  Future<void> _handleContinue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isChecking = true;
      _serverError = null;
    });

    final phoneNumber = '+91${_controller.text}';
    final authService = AuthService();
    
    try {
      final isTaken = await authService.isPhoneRegistered(phoneNumber);
      if (isTaken) {
        setState(() {
          _serverError = 'This number is already linked to another account. Use a different number or contact support.';
          _isChecking = false;
        });
      } else {
        widget.onSaved(phoneNumber);
      }
    } catch (e) {
      setState(() {
        _serverError = 'Verification failed. Please try again.';
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter your mobile number',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This is private. Never shown publicly. Used only for account recovery.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          AppPhoneField(
            controller: _controller,
            onChanged: _checkValidity,
          ),
          if (_serverError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _serverError!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: (_isValid && !_isChecking) ? _handleContinue : null,
              child: _isChecking
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Continue', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
