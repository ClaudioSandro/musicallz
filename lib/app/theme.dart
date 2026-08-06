import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/theme/app_theme_config.dart';
import '../core/theme/theme_extension.dart';
import '../core/theme/theme_models.dart';

/// Builds the app [ThemeData] from the active [ThemeState] and brightness.
///
/// All UI colors flow from here: the selected palette drives the
/// [ColorScheme], the scaffold background and the custom [AppThemeExtension]
/// tokens used by headers and dynamic backdrops.
abstract final class AppTheme {
  static ThemeData build({
    required ThemeState state,
    required Brightness brightness,
  }) {
    final palette = paletteById(state.palette);
    final colors = brightness == Brightness.dark
        ? palette
        : palette.light();
    final onAccent = _foregroundOn(palette.primary);

    final scheme = ColorScheme.fromSeed(
      seedColor: palette.primary,
      brightness: brightness,
      surface: colors.surface,
    ).copyWith(
      primary: palette.primary,
      onPrimary: onAccent,
      secondary: palette.secondary,
      onSecondary: _foregroundOn(palette.secondary),
      surface: colors.surface,
      onSurface: colors.text,
      onSurfaceVariant: colors.textSecondary,
      outline: colors.divider,
      outlineVariant: colors.divider,
      surfaceContainerLowest: colors.background,
      surfaceContainerLow: colors.surface,
      surfaceContainer: colors.card,
      surfaceContainerHigh: colors.surfaceHigh,
      surfaceContainerHighest: colors.surfaceHigh,
    );

    final base = brightness == Brightness.dark
        ? FlexThemeData.dark(
            colors: FlexSchemeColor.from(
              primary: palette.primary,
              secondary: palette.secondary,
              brightness: Brightness.dark,
            ),
            colorScheme: scheme,
            surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
            appBarStyle: FlexAppBarStyle.background,
            scaffoldBackground: colors.background,
            useMaterial3: true,
          )
        : FlexThemeData.light(
            colors: FlexSchemeColor.from(
              primary: palette.primary,
              secondary: palette.secondary,
              brightness: Brightness.light,
            ),
            colorScheme: scheme,
            surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
            appBarStyle: FlexAppBarStyle.background,
            scaffoldBackground: colors.background,
            useMaterial3: true,
          );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: colors.text,
        displayColor: colors.text,
      ),
      dividerTheme: DividerThemeData(
        color: colors.divider.withValues(alpha: 0.12),
        thickness: 1,
      ),
      navigationBarTheme: _navigationBarTheme(
        colors: colors,
        palette: palette,
        brightness: brightness,
      ),
      extensions: [
        AppThemeExtension(
          gradientStart: palette.gradient.first,
          gradientEnd: palette.gradient.last,
          headerTextColor: Colors.white,
          headerTextMuted: Colors.white70,
          overlayDivider: Colors.white24,
          backgroundStyle: state.backgroundStyle,
          intensity: state.intensity,
        ),
      ],
    );
  }

  static NavigationBarThemeData _navigationBarTheme({
    required ThemePalette colors,
    required ThemePalette palette,
    required Brightness brightness,
  }) {
    final dark = brightness == Brightness.dark;
    // Selected items sit on a pill filled with the accent. In dark mode the
    // icon must contrast against that pill (white, or black when the accent is
    // very light like AMOLED's), otherwise it blends in and becomes invisible.
    final indicator = palette.primary.withValues(alpha: dark ? 0.9 : 0.16);
    final selectedForeground = dark
        ? (palette.primary.computeLuminance() > 0.5
            ? Colors.black
            : Colors.white)
        : palette.primary;
    return NavigationBarThemeData(
      backgroundColor: colors.surface,
      indicatorColor: indicator,
      surfaceTintColor: Colors.transparent,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? selectedForeground : colors.textSecondary,
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? selectedForeground : colors.textSecondary,
        );
      }),
    );
  }

  static Color _foregroundOn(Color color) =>
      color.computeLuminance() > 0.4 ? Colors.black : Colors.white;
}
