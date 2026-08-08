import 'package:flutter/material.dart';

/// How the app follows the device appearance.
enum ThemeModeOption { system, light, dark }

/// The available color palettes.
enum ThemePaletteId {
  spotifyGreen,
  oceanBlue,
  deepPurple,
  sunsetOrange,
  crimsonRed,
  monochrome,
  amoledBlack,
}

/// How the dynamic backgrounds are rendered.
enum BackgroundStyle { gradient, solid, softBlur, strongBlur, dynamic }

/// How strong the background tint / blur is.
enum BackgroundIntensity { low, medium, high }

/// Immutable appearance configuration. The single source of truth for the
/// whole theming system, persisted through [ThemeRepository].
class ThemeState {
  const ThemeState({
    this.mode = ThemeModeOption.dark,
    this.palette = ThemePaletteId.spotifyGreen,
    this.backgroundStyle = BackgroundStyle.gradient,
    this.intensity = BackgroundIntensity.medium,
  });

  final ThemeModeOption mode;
  final ThemePaletteId palette;
  final BackgroundStyle backgroundStyle;
  final BackgroundIntensity intensity;

  /// Flutter equivalent used by [MaterialApp.themeMode].
  ThemeMode get themeMode => switch (mode) {
        ThemeModeOption.system => ThemeMode.system,
        ThemeModeOption.light => ThemeMode.light,
        ThemeModeOption.dark => ThemeMode.dark,
      };

  ThemeState copyWith({
    ThemeModeOption? mode,
    ThemePaletteId? palette,
    BackgroundStyle? backgroundStyle,
    BackgroundIntensity? intensity,
  }) {
    return ThemeState(
      mode: mode ?? this.mode,
      palette: palette ?? this.palette,
      backgroundStyle: backgroundStyle ?? this.backgroundStyle,
      intensity: intensity ?? this.intensity,
    );
  }
}

extension BackgroundIntensityValues on BackgroundIntensity {
  /// How far the palette colors are blended toward black for dark backdrops.
  double get blendFactor => switch (this) {
        BackgroundIntensity.low => 0.48,
        BackgroundIntensity.medium => 0.65,
        BackgroundIntensity.high => 0.82,
      };

  /// Blur radius (logical pixels) used by the soft/strong blur styles.
  double get blurSigma => switch (this) {
        BackgroundIntensity.low => 18,
        BackgroundIntensity.medium => 34,
        BackgroundIntensity.high => 54,
      };

  String get label => switch (this) {
        BackgroundIntensity.low => 'Bajo',
        BackgroundIntensity.medium => 'Medio',
        BackgroundIntensity.high => 'Alto',
      };
}

extension BackgroundStyleValues on BackgroundStyle {
  String get label => switch (this) {
        BackgroundStyle.gradient => 'Degradado',
        BackgroundStyle.solid => 'Sólido',
        BackgroundStyle.softBlur => 'Blur suave',
        BackgroundStyle.strongBlur => 'Blur intenso',
        BackgroundStyle.dynamic => 'Dinámico',
      };

  String get description => switch (this) {
        BackgroundStyle.gradient => 'Degradado de la paleta',
        BackgroundStyle.solid => 'Fondo plano',
        BackgroundStyle.softBlur => 'Difuminado suave',
        BackgroundStyle.strongBlur => 'Difuminado intenso',
        BackgroundStyle.dynamic => 'Colores de la portada',
      };
}

extension ThemeModeOptionValues on ThemeModeOption {
  String get label => switch (this) {
        ThemeModeOption.system => 'Sistema',
        ThemeModeOption.light => 'Claro',
        ThemeModeOption.dark => 'Oscuro',
      };
}
