import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:midical_project4/ui/pages/login_page.dart';
import 'package:midical_project4/ui/pages/signup_page.dart';
import 'package:midical_project4/ui/pages/welcome_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'features/blind/vision_page.dart';
import 'features/deaf/chat_page.dart';
import 'features/mute/mute_page.dart';
import 'features/onboarding/onboarding_page.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final seenOnboarding = prefs.getBool('seen_onboarding') ?? true;

  runApp(MyApp(seenOnboarding: seenOnboarding));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.seenOnboarding});

  final bool seenOnboarding;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مُساعِد الصحة',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
      ),
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: seenOnboarding ? '/onboarding' : '/onboarding',
      routes: {
        '/onboarding': (_) => const OnboardingScreen(),
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/home_deaf': (_) => const HomeDeafScreen (),
        '/home_mute': (_) => const HomeMute(),
        '/home_blind': (_) => const BlindPage(),
        '/welcome': (_) => const WelcomeScreen(),
      },
    );
  }
}