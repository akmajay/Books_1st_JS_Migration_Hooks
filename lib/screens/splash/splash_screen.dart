import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../services/auth_service.dart';
import '../../services/app_config_service.dart';
import '../../models/app_config_model.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late Animation<double> _logoFade;
  late Animation<double> _textFade;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _logoFade = CurvedAnimation(parent: _logoController, curve: Curves.easeIn);
    _textFade = CurvedAnimation(parent: _textController, curve: Curves.easeIn);

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _textController.forward();
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    final authService = context.read<AuthService>();

    // Run checks in parallel with minimum splash duration
    final results = await Future.wait([
      AppConfigService.instance.fetch(),       // 1. Fetch app config
      _getAppVersion(),                        // 2. Get runtime version
      _checkAuthAndStatus(authService),        // 3. Check auth state
      Future.delayed(const Duration(seconds: 2)), // Minimum splash time
    ]);

    final config = results[0] as AppConfigModel;
    final currentVersion = results[1] as String;
    final String authRoute = results[2] as String;

    if (!mounted) return;

    // Gate checks in order: maintenance → force update → auth
    if (config.maintenanceMode) {
      context.go('/maintenance');
      return;
    }

    if (AppConfigService.instance.isForceUpdateRequired(currentVersion)) {
      context.go('/force-update');
      return;
    }

    context.go(authRoute);
  }

  Future<String> _getAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      return info.version;
    } catch (_) {
      return '1.0.0';
    }
  }

  Future<String> _checkAuthAndStatus(AuthService auth) async {
    if (!auth.isLoggedIn) return '/home';

    try {
      final user = await auth.refreshUser();
      if (user == null) return '/home';

      if (user.isBanned) return '/banned';
      if (!user.onboardingComplete) return '/onboarding';

      return '/home';
    } catch (e) {
      return '/home';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: _logoFade,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(Icons.menu_book_rounded, size: 60, color: Colors.white),
              ),
            ),
            const SizedBox(height: 32),
            FadeTransition(
              opacity: _textFade,
              child: Column(
                children: [
                  Text(
                    'JayGanga Books',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Buy & Sell Used Books Near You',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
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
}
