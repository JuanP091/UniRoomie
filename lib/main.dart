import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/start_screen.dart';
import 'screens/recovery_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login App',
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/start': (context) => const StartScreen(),
        '/recover': (context) => const RecoverAccountScreen(),
      },
    );
  }
}
