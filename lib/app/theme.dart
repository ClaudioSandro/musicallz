import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTheme {
  static const Color _accent = Color(0xFF1DB954);
  static const Color _scaffold = Color(0xFF121212);

  static ThemeData get dark {
    final base = FlexThemeData.dark(
      colors: FlexSchemeColor.from(
        primary: _accent,
        brightness: Brightness.dark,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: _accent,
        brightness: Brightness.dark,
        surface: _scaffold,
      ).copyWith(
        primary: _accent,
        surface: _scaffold,
        onSurface: const Color(0xFFE8E8E8),
        onSurfaceVariant: const Color(0xFFB3B3B3),
      ),
      surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
      appBarStyle: FlexAppBarStyle.background,
      scaffoldBackground: _scaffold,
      useMaterial3: true,
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: const Color(0xFFE8E8E8),
        displayColor: const Color(0xFFE8E8E8),
      ),
    );
  }
}