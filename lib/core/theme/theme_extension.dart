import 'package:flutter/material.dart';

import 'theme_models.dart';

/// Semantic theme tokens that live outside the Material [ColorScheme]:
/// header gradients, overlay text and the active background configuration.
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  const AppThemeExtension({
    required this.gradientStart,
    required this.gradientEnd,
    required this.headerTextColor,
    required this.headerTextMuted,
    required this.overlayDivider,
    required this.backgroundStyle,
    required this.intensity,
  });

  final Color gradientStart;
  final Color gradientEnd;
  final Color headerTextColor;
  final Color headerTextMuted;
  final Color overlayDivider;
  final BackgroundStyle backgroundStyle;
  final BackgroundIntensity intensity;

  double get blendFactor => intensity.blendFactor;

  @override
  AppThemeExtension copyWith({
    Color? gradientStart,
    Color? gradientEnd,
    Color? headerTextColor,
    Color? headerTextMuted,
    Color? overlayDivider,
    BackgroundStyle? backgroundStyle,
    BackgroundIntensity? intensity,
  }) {
    return AppThemeExtension(
      gradientStart: gradientStart ?? this.gradientStart,
      gradientEnd: gradientEnd ?? this.gradientEnd,
      headerTextColor: headerTextColor ?? this.headerTextColor,
      headerTextMuted: headerTextMuted ?? this.headerTextMuted,
      overlayDivider: overlayDivider ?? this.overlayDivider,
      backgroundStyle: backgroundStyle ?? this.backgroundStyle,
      intensity: intensity ?? this.intensity,
    );
  }

  @override
  AppThemeExtension lerp(ThemeExtension<AppThemeExtension>? other, double t) {
    if (other is! AppThemeExtension) return this;
    return AppThemeExtension(
      gradientStart: Color.lerp(gradientStart, other.gradientStart, t)!,
      gradientEnd: Color.lerp(gradientEnd, other.gradientEnd, t)!,
      headerTextColor:
          Color.lerp(headerTextColor, other.headerTextColor, t)!,
      headerTextMuted: Color.lerp(headerTextMuted, other.headerTextMuted, t)!,
      overlayDivider: Color.lerp(overlayDivider, other.overlayDivider, t)!,
      backgroundStyle: t < 0.5 ? backgroundStyle : other.backgroundStyle,
      intensity: t < 0.5 ? intensity : other.intensity,
    );
  }
}

extension AppThemeContext on BuildContext {
  /// Shorthand access to the custom theme tokens. Falls back to the default
  /// Spotify palette when the themed [MaterialApp] is not in the tree (e.g.
  /// widget tests that pump screens under a plain `MaterialApp`).
  AppThemeExtension get appTheme =>
      Theme.of(this).extension<AppThemeExtension>() ?? _kDefaultThemeTokens;

  /// Brand accent for text/icons sitting on a surface. Falls back to the
  /// surface foreground when the palette primary is too light to be read on a
  /// light background (e.g. the AMOLED/monochrome palettes in light mode).
  Color get brandAccent {
    final theme = Theme.of(this);
    final primary = theme.colorScheme.primary;
    final isLight = theme.brightness == Brightness.light;
    if (isLight && primary.computeLuminance() > 0.45) {
      return theme.colorScheme.onSurface;
    }
    return primary;
  }
}

const AppThemeExtension _kDefaultThemeTokens = AppThemeExtension(
  gradientStart: Color(0xFF1DB954),
  gradientEnd: Color(0xFF0B5C33),
  headerTextColor: Colors.white,
  headerTextMuted: Colors.white70,
  overlayDivider: Colors.white24,
  backgroundStyle: BackgroundStyle.gradient,
  intensity: BackgroundIntensity.medium,
);
