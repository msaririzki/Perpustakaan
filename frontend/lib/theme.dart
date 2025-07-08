import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData appTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF6C63FF), // ungu muda
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: const Color(0xFF6C63FF),
    secondary: const Color(0xFFFFC93C), // kuning aksen
    background: Colors.white,
  ),
  scaffoldBackgroundColor: Colors.white,
  textTheme: GoogleFonts.poppinsTextTheme(),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0,
    iconTheme: IconThemeData(color: Color(0xFF6C63FF)),
    titleTextStyle: TextStyle(
      color: Color(0xFF22223B),
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF6C63FF)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF6C63FF),
    foregroundColor: Colors.white,
  ),
);
