import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'firebase_options.dart';

// services
import 'services/auth_service.dart';
import 'services/food_service.dart';
import 'services/storage_service.dart';
import 'services/user_service.dart';
import 'services/activity_service.dart';


// providers
import 'providers/auth_provider.dart';
import 'providers/food_provider.dart';
import 'providers/user_provider.dart';
import 'providers/activity_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        /// SERVICES
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<FoodService>(create: (_) => FoodService()),
        Provider<StorageService>(create: (_) => StorageService()),

        /// AUTH PROVIDER
        ChangeNotifierProxyProvider<AuthService, AuthProvider>(
          create: (context) =>
              AuthProvider(authService: context.read<AuthService>()),
          update: (context, authService, previous) =>
              previous ?? AuthProvider(authService: authService),
        ),

        /// FOOD PROVIDER
        ChangeNotifierProxyProvider2<FoodService, StorageService, FoodProvider>(
          create: (context) => FoodProvider(
            foodService: context.read<FoodService>(),
            storageService: context.read<StorageService>(),
          ),
          update: (context, foodService, storageService, previous) =>
              previous ??
              FoodProvider(
                foodService: foodService,
                storageService: storageService,
              ),
        ),

        ChangeNotifierProvider(
          create: (_) => UserProvider(userService: UserService()),
        ),

        ChangeNotifierProvider(
          create: (_) => ActivityProvider(activityService: ActivityService()),
        ),
      ],
      child: const MyApp(),
    ),
  );
}
