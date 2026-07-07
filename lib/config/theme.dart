import 'package:flutter/material.dart';

/// Paleta y tema global de Guardian.
///
/// Paleta requerida por el Project Kit:
///   - Azul oscuro  -> color primario / marca (confianza, seguridad)
///   - Blanco       -> fondos y superficies
///   - Gris         -> textos secundarios, bordes, campos deshabilitados
///   - Rojo         -> acentos de alerta / incidentes (siempre asociado
///                     a "peligro" o "reporte", nunca a acciones neutras)
class AppColors {
  AppColors._();

  static const Color darkBlue = Color(0xFF0D1B3E);
  static const Color primaryBlue = Color(0xFF1B3A6B);
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray = Color(0xFF6B7280);
  static const Color lightGray = Color(0xFFF3F4F6);
  static const Color alertRed = Color(0xFFD32F2F);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.white,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.darkBlue,
        primary: AppColors.darkBlue,
        secondary: AppColors.primaryBlue,
        error: AppColors.alertRed,
        surface: AppColors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBlue,
        foregroundColor: AppColors.white,
        centerTitle: true,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: AppColors.gray.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: AppColors.darkBlue, width: 1.5),
        ),
        filled: true,
        fillColor: AppColors.lightGray,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(color: AppColors.gray),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.darkBlue,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.alertRed,
        foregroundColor: AppColors.white,
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(color: Color(0xFF1F2937)),
      ),
    );
  }
}
