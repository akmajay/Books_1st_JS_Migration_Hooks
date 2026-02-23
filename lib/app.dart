import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'router/app_router.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme.dart';

/// Root application widget for JayGanga Books.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, AuthService>(
      builder: (context, themeProvider, authService, child) {
        return MaterialApp.router(
          title: 'JayGanga Books',
          debugShowCheckedModeBanner: false,

          // Themes
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeProvider.themeMode,

          // Routing
          routerConfig: AppRouter.getRouter(authService),
        );
      },
    );
  }
}
