// lib/main.dart

import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'sign_up_page.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'forgot_password_page.dart';
import 'news_page.dart';
import 'explore_page.dart';
import 'portfolio_page.dart'; // Import the PortfolioPage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ThemeData appTheme = ThemeData.dark().copyWith(
      primaryColor: Colors.blue,
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.blueAccent, // Updated for TextButton
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue, // Updated for ElevatedButton
          foregroundColor: Colors.white, // Updated for ElevatedButton text
        ),
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BoursaSmart',
      theme: appTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/signup': (context) => const SignUpPage(),
        '/login': (context) => const LoginPage(),
        '/forgot-password': (context) => const ForgotPasswordPage(),
        '/home': (context) => const HomePage(),
        '/news': (context) => const NewsPage(),
        '/explore': (context) => const ExplorePage(),
        '/portfolio': (context) => const PortfolioPage(), // Added PortfolioPage route
      },
    );
  }
}