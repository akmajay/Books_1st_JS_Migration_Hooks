import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/validators.dart';
import '../../widgets/forms/app_text_field.dart';
import '../../widgets/forms/app_phone_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final Map<String, dynamic> _formData = {};

  @override
  void initState() {
    super.initState();
    final user = _authService.currentUser;
    if (user != null) {
      _formData['name'] = user.name;
      _formData['email'] = user.email;
      _formData['phone'] = user.phone;
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Update logic here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [IconButton(icon: const Icon(Icons.check), onPressed: _save)],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppTextField(
              label: 'Full Name',
              initialValue: _formData['name']?.toString(),
              validator: (v) => AppValidators.required(v, 'Name is required'),
              onSaved: (v) => _formData['name'] = v,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Email',
              initialValue: _formData['email']?.toString(),
              validator: AppValidators.email,
              onSaved: (v) => _formData['email'] = v,
            ),
            const SizedBox(height: 16),
            AppPhoneField(
              onChanged: (v) => _formData['phone'] = v,
            ),
          ],
        ),
      ),
    );
  }
}
