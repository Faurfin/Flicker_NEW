import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Импорт твоего нового экрана онбординга
import 'onboarding_screen.dart';
// Импорт экрана авторизации из твоей структуры
import 'features/auth/ui/login_screen.dart'; 

void main() async {
  // Обязательная строка перед вызовом SharedPreferences до runApp
  WidgetsFlutterBinding.ensureInitialized();
  
  // Проверяем, запускалось ли приложение раньше
  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

  runApp(FlickerApp(isFirstLaunch: isFirstLaunch));
}

class FlickerApp extends StatelessWidget {
  final bool isFirstLaunch;

  const FlickerApp({super.key, required this.isFirstLaunch});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flicker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Темный фон по умолчанию под новый дизайн
        scaffoldBackgroundColor: const Color(0xFF0A0A0A), 
        useMaterial3: true,
      ),
      // Если первый запуск — показываем Onboarding, иначе — LoginScreen
      home: isFirstLaunch ? const OnboardingScreen() : LoginScreen(),
    );
  }
}