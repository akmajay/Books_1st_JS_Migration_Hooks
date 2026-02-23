import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/page_transitions.dart';

import '../services/auth_service.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/onboarding_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/book/book_detail_screen.dart';
import '../screens/book/edit_book_screen.dart';
import '../screens/sell/sell_book_screen.dart';
import '../screens/profile/manage_listings_screen.dart';
import '../screens/chat/chat_detail_screen.dart';
import '../screens/chat/chat_list_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/shell/app_shell.dart';
import '../screens/transaction/transaction_detail_screen.dart';
import '../screens/transaction/qr_code_screen.dart';
import '../screens/transaction/qr_scan_screen.dart';
import '../screens/transaction/review_screen.dart';
import '../screens/status/banned_screen.dart';
import '../screens/status/force_update_screen.dart';
import '../screens/status/maintenance_screen.dart';
import '../screens/profile/seller_profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/transactions_list_screen.dart';
import '../screens/profile/wishlist_screen.dart';
import '../screens/profile/badge_showcase_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/blocked_users_screen.dart';
import '../screens/settings/notification_settings_screen.dart';
import '../screens/notifications/notification_center_screen.dart';
import '../screens/profile/referral_screen.dart';
import '../screens/report/report_screen.dart';
import '../screens/profile/academic_profile_edit_screen.dart';

class StubScreen extends StatelessWidget {
  final String title;
  const StubScreen({super.key, required this.title});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: Center(child: Text('$title - Coming Soon')),
  );
}

class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _homeNavigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _searchNavigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _sellNavigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _chatsNavigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _profileNavigatorKey = GlobalKey<NavigatorState>();
  
  static GoRouter? _router;
  static GoRouter get router => _router!;

  static GoRouter getRouter(AuthService authService) {
    _router ??= GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: authService,
      redirect: (context, state) {
        final isLoggedIn = authService.isLoggedIn;
      
      // EXCEPTION: /onboarding requires actual auth. 
      // If user isn't logged in, they can't be onboarding.
      if (state.matchedLocation == '/onboarding' && !isLoggedIn) {
        return '/home';
      }

      // If user IS logged in but hasn't completed onboarding
      // Redirect them to onboarding unless they are already there
      if (isLoggedIn && 
          authService.currentUser != null && 
          !authService.currentUser!.onboardingComplete && 
          state.matchedLocation != '/onboarding' &&
          !state.matchedLocation.startsWith('/onboarding')) {
        return '/onboarding';
      }

      return null;
    },
    routes: [
      // Splash
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth Required (Hard Redirect)
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              AppPageTransitions.fadeIn(child).transitionsBuilder(
            context, animation, secondaryAnimation, child,
          ),
          transitionDuration: const Duration(milliseconds: 200),
        ),
      ),

      // Status Screens
      GoRoute(path: '/banned', builder: (context, state) => const BannedScreen()),
      GoRoute(path: '/force-update', builder: (context, state) => const ForceUpdateScreen()),
      GoRoute(path: '/maintenance', builder: (context, state) => const MaintenanceScreen()),

      // Main Shell (Bottom Nav)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          // HOME TAB
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // SEARCH TAB
          StatefulShellBranch(
            navigatorKey: _searchNavigatorKey,
            routes: [
              GoRoute(
                path: '/home/search',
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          // SELL TAB
          StatefulShellBranch(
            navigatorKey: _sellNavigatorKey,
            routes: [
              GoRoute(
                path: '/home/sell',
                pageBuilder: (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const SellBookScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                      AppPageTransitions.slideUp(child).transitionsBuilder(
                    context, animation, secondaryAnimation, child,
                  ),
                  transitionDuration: const Duration(milliseconds: 250),
                ),
              ),
            ],
          ),
          // CHATS TAB
          StatefulShellBranch(
            navigatorKey: _chatsNavigatorKey,
            routes: [
              GoRoute(
                path: '/home/chats',
                builder: (context, state) => const ChatListScreen(),
              ),
            ],
          ),
          // PROFILE TAB
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: '/home/profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'listings',
                    builder: (context, state) => const ManageListingsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // Standalone Routes (accessible from anywhere)
      GoRoute(
        path: '/book/:id',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: BookDetailScreen(bookId: state.pathParameters['id']!),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              AppPageTransitions.sharedAxisX(child).transitionsBuilder(
            context, animation, secondaryAnimation, child,
          ),
          transitionDuration: const Duration(milliseconds: 300),
        ),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) => EditBookScreen(bookId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: '/seller/:id',
        builder: (context, state) => SellerProfileScreen(userId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/chat/:id',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: ChatDetailScreen(chatId: state.pathParameters['id']!),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              AppPageTransitions.sharedAxisX(child).transitionsBuilder(
            context, animation, secondaryAnimation, child,
          ),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      ),
      GoRoute(
        path: '/transaction/:id',
        builder: (context, state) => TransactionDetailScreen(transactionId: state.pathParameters['id']!),
        routes: [
          GoRoute(path: 'qr', builder: (context, state) => QrCodeScreen(transactionId: state.pathParameters['id']!)),
          GoRoute(path: 'scan', builder: (context, state) => QrScanScreen(transactionId: state.pathParameters['id']!)),
          GoRoute(path: 'review', builder: (context, state) => ReviewScreen(transactionId: state.pathParameters['id']!)),
        ],
      ),
      GoRoute(
        path: '/notifications', 
        builder: (context, state) => const NotificationCenterScreen()
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
        routes: [
          GoRoute(path: 'profile-edit', builder: (context, state) => const EditProfileScreen()),
          GoRoute(path: 'blocked-users', builder: (context, state) => const BlockedUsersScreen()),
          GoRoute(path: 'notifications', builder: (context, state) => const NotificationSettingsScreen()),
          GoRoute(path: 'academic-profile', builder: (context, state) => const AcademicProfileEditScreen()),
        ],
      ),
      GoRoute(path: '/transactions', builder: (context, state) => const TransactionsListScreen()),
      GoRoute(path: '/wishlists', builder: (context, state) => const WishlistScreen()),
      GoRoute(path: '/badges', builder: (context, state) => const BadgeShowcaseScreen()),
      GoRoute(path: '/referral', builder: (context, state) => const ReferralScreen()),
      GoRoute(
        path: '/report/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final title = state.uri.queryParameters['title'] ?? 'Listing';
          return ReportScreen(bookId: id, bookTitle: title);
        },
      ),
    ],
  );
  return _router!;
}
}
