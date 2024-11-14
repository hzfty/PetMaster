import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    // Устанавливаем цвет фона приложения
    scaffoldBackgroundColor: AppColors.elevation,

    // Настраиваем цветовую схему
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.white,
      secondary: AppColors.secondary,
      onSecondary: AppColors.white,
      surface: AppColors.surface,
      onSurface: AppColors.black,
      error: Colors.red,
      onError: AppColors.white,
    ),

    // Настраиваем AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
    ),

    // Настраиваем TextTheme с использованием новых свойств
    textTheme: TextTheme(
      // Заголовки
      displayLarge: TextStyle(
          fontSize: 96, fontWeight: FontWeight.bold, color: AppColors.black),
      displayMedium: TextStyle(
          fontSize: 60, fontWeight: FontWeight.bold, color: AppColors.black),
      displaySmall: TextStyle(
          fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.black),
      headlineLarge: TextStyle(
          fontSize: 34, fontWeight: FontWeight.bold, color: AppColors.black),
      headlineMedium: TextStyle(
          fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.black),
      headlineSmall: TextStyle(
          fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.black),

      // Тело текста
      bodyLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.normal, color: AppColors.black),
      bodyMedium: TextStyle(
          fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.black),
      bodySmall: TextStyle(
          fontSize: 12, fontWeight: FontWeight.normal, color: AppColors.black),

      // Подписи
      titleLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.normal, color: AppColors.black),
      titleMedium: TextStyle(
          fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.black),
      titleSmall: TextStyle(
          fontSize: 12, fontWeight: FontWeight.normal, color: AppColors.black),

      // Метки и кнопки
      labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.white), // Для кнопок
      labelMedium: TextStyle(
          fontSize: 12, fontWeight: FontWeight.normal, color: AppColors.black),
      labelSmall: TextStyle(
          fontSize: 10, fontWeight: FontWeight.normal, color: AppColors.black),
    ),

    // Настраиваем ElevatedButton
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        minimumSize: Size(double.infinity, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.white, // Цвет текста на кнопке
        ),
      ),
    ),

    // Настраиваем OutlinedButton
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: AppColors.primary),
        foregroundColor: AppColors.primary,
        minimumSize: Size(double.infinity, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.primary, // Цвет текста на кнопке
        ),
      ),
    ),

    // Настраиваем TextButton
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppColors.primary, // Цвет текста на кнопке
        ),
      ),
    ),

    // Настраиваем InputDecorationTheme
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      hintStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w300,
        color: AppColors.gray03,
      ),
      labelStyle: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w300,
        color: AppColors.gray03,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide(color: AppColors.gray03),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide(color: AppColors.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.0),
        borderSide: BorderSide(color: Colors.red),
      ),
    ),

    // Настраиваем BottomNavigationBar
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.gray02,
    ),
  );
}
