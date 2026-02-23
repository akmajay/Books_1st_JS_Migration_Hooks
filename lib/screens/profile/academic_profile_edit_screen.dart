import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../auth/steps/academic_profile_step.dart';

class AcademicProfileEditScreen extends StatelessWidget {
  const AcademicProfileEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.currentUser;

    if (user == null) return const Scaffold(body: Center(child: Text('Please sign in')));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Academic Profile'),
        elevation: 0,
      ),
      body: AcademicProfileStep(
        initialData: user.toJson(),
        onSaved: (newData) async {
          try {
            // Show loading
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => const Center(child: CircularProgressIndicator()),
            );

            await authService.updateProfile(newData);
            
            if (context.mounted) {
              Navigator.pop(context); // Pop loading
              Navigator.pop(context); // Pop edit screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Academic profile updated successfully!')),
              );
            }
          } catch (e) {
            if (context.mounted) {
              Navigator.pop(context); // Pop loading
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error updating profile: $e')),
              );
            }
          }
        },
        onSkip: () => Navigator.pop(context),
      ),
    );
  }
}
