import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/bills/screens/bill_form_screen.dart';
import '../features/bills/screens/bills_screen.dart';
import '../features/calendar/screens/calendar_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/settings/screens/upgrade_screen.dart';
import '../features/settings/screens/edit_profile_screen.dart';
import '../features/settings/screens/about_screen.dart';
import '../features/stats/screens/stats_screen.dart';
import '../global_widgets/main_scaffold.dart';

GoRouter buildRouter(Ref ref) {
  final auth = ref.watch(authProvider);
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      if (auth.isLoading) return null;
      if (state.uri.path == '/') {
        return auth.isLoggedIn ? '/home' : '/login';
      }
      if (!auth.isPro && state.uri.path == '/stats') {
        return '/upgrade';
      }
      final path = state.uri.path;
      final isAuthRoute = path.startsWith('/login') || path.startsWith('/signup');
      if (!auth.isLoggedIn && !isAuthRoute) return '/login';
      if (auth.isLoggedIn && isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: LoginScreen.routeName,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: SignupScreen.routeName,
        builder: (context, state) => const SignupScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            name: HomeScreen.routeName,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/calendar',
            name: CalendarScreen.routeName,
            builder: (context, state) => const CalendarScreen(),
          ),
          GoRoute(
            path: '/bills',
            name: BillsScreen.routeName,
            builder: (context, state) => const BillsScreen(),
          ),
          GoRoute(
            path: '/bills/form',
            name: BillFormScreen.routeName,
            builder: (context, state) => const BillFormScreen(),
          ),
          GoRoute(
            path: '/bills/form/:id',
            name: BillFormScreen.editRouteName,
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '');
              return BillFormScreen(billId: id);
            },
          ),
          GoRoute(
            path: '/stats',
            name: StatsScreen.routeName,
            builder: (context, state) => const StatsScreen(),
          ),
          GoRoute(
            path: '/settings',
            name: SettingsScreen.routeName,
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/upgrade',
            name: UpgradeScreen.routeName,
            builder: (context, state) => const UpgradeScreen(),
          ),
          GoRoute(
            path: '/settings/edit-profile',
            name: EditProfileScreen.routeName,
            builder: (context, state) => const EditProfileScreen(),
          ),
          GoRoute(
            path: '/settings/about',
            name: AboutScreen.routeName,
            builder: (context, state) => const AboutScreen(),
          ),
        ],
      ),
    ],
  );
}
