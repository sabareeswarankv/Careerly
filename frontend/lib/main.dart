import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/app_theme.dart';
import 'config/constants.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/storage_service.dart';
import 'providers/auth_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/guidance_provider.dart';
import 'providers/interview_provider.dart';
import 'providers/resume_provider.dart';
import 'firebase_options.dart';
import 'screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  final apiService = ApiService();
  final authService = AuthService();
  final storageService = StorageService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
        ChangeNotifierProvider(create: (_) => ProfileProvider(storageService, apiService)),
        ChangeNotifierProvider(create: (_) => GuidanceProvider(apiService, storageService)),
        ChangeNotifierProvider(create: (_) => InterviewProvider(apiService)),
        ChangeNotifierProvider(create: (_) => ResumeProvider(apiService)),
      ],
      child: const CareerlyApp(),
    ),
  );
}

class CareerlyApp extends StatelessWidget {
  const CareerlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
