import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'steps/mobile_number_step.dart';
import 'steps/location_step.dart';
import 'steps/academic_profile_step.dart';
import 'steps/notification_step.dart';
import 'steps/terms_step.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final Map<String, dynamic> _collectedData = {};

  void _nextPage() {
    if (_currentStep < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onStepDataSaved(Map<String, dynamic> data) {
    setState(() {
      _collectedData.addAll(data);
    });
    _nextPage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: _previousPage,
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: MobileNumberStep(
                      initialValue: _collectedData['phone'],
                      onSaved: (phone) => _onStepDataSaved({'phone': phone}),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: LocationStep(
                      initialData: _collectedData,
                      onSaved: _onStepDataSaved,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(1.0), // Less padding for scrollable content
                    child: AcademicProfileStep(
                      initialData: _collectedData,
                      onSaved: _onStepDataSaved,
                      onSkip: _nextPage,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: NotificationStep(
                      onContinue: _nextPage,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: TermsStep(
                      collectedData: _collectedData,
                      onComplete: () => context.go('/home'),
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

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        LinearProgressIndicator(
          value: (_currentStep + 1) / 5,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          minHeight: 6,
        ),
        const SizedBox(height: 12),
        Text(
          'Step ${_currentStep + 1} of 5',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
