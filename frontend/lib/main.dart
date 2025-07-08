import 'package:flutter/material.dart';
import 'package:frontend/screens/page_manager.dart';
import 'package:frontend/screens/register_screen.dart';
import 'screens/login_screen.dart';
import 'theme.dart';

void main() => runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: appTheme,
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/dashboard': (context) => const PageManager(),
        },
      ),
    );
