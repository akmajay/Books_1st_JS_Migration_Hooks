import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'services/pocketbase_service.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'services/search_history_service.dart';
import 'providers/theme_provider.dart';
import 'providers/search_provider.dart';
import 'providers/notification_provider.dart';
import 'services/deep_link_service.dart';
import 'services/connectivity_service.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Core configurations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Storage and Services
  await Hive.initFlutter();
  await Hive.openBox('sell_draft');
  await Hive.openBox('settings');
  await SearchHistoryService.init();
  await PocketBaseService.instance.initialize();
  await NotificationService.instance.initialize();
  await DeepLinkService.instance.initialize();
  
  final authService = AuthService();
  final themeProvider = ThemeProvider();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authService),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityService()),
      ],
      child: const App(),
    ),
  );
}
