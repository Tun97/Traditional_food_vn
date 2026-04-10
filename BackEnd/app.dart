import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/routes/app_routes.dart';
import 'core/themes/app_theme.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/splash/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Vietnamese Food App',
          theme: AppTheme.lightTheme,
          routes: AppRoutes.routes,
          home: _buildHome(authProvider),
        );
      },
    );
  }

  Widget _buildHome(AuthProvider authProvider) {
    if (authProvider.isInitializing) {
      return const SplashScreen();
    }

    if (authProvider.currentUser != null) {
      return const HomeScreen();
    }

    return const LoginScreen();
  }
}