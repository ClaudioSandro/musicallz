import 'package:flutter/material.dart';

import 'theme_models.dart';

/// A full color palette. Values are given for dark mode; [light] derives a
/// coherent light variant from the same accent colors.
class ThemePalette {
  const ThemePalette({
    required this.id,
    required this.name,
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.surfaceHigh,
    required this.card,
    required this.icon,
    required this.text,
    required this.textSecondary,
    required this.divider,
    required this.gradient,
  });

  final ThemePaletteId id;
  final String name;

  /// Accent used for the primary actions (play button, active controls).
  final Color primary;
  final Color secondary;

  /// Scaffold background color.
  final Color background;

  /// Main surface color (bottom bar, mini player, sheets).
  final Color surface;

  /// Slightly elevated surface (seek track, avatars, placeholders).
  final Color surfaceHigh;

  /// Card / container fills.
  final Color card;

  /// Icon color.
  final Color icon;

  /// Primary text color.
  final Color text;

  /// Muted text / secondary icons.
  final Color textSecondary;

  /// Divider / outline color.
  final Color divider;

  /// Brand gradient used for headers and dynamic backdrops.
  final List<Color> gradient;

  /// Returns the palette for [Brightness.light], reusing the same accents.
  ThemePalette light() {
    final onAccent = _foregroundOn(primary);
    return ThemePalette(
      id: id,
      name: name,
      primary: primary,
      secondary: secondary,
      background: _mixWithWhite(primary, 0.94, 0xFFF7F7F7),
      surface: _mixWithWhite(primary, 0.9, 0xFFFFFFFF),
      surfaceHigh: _mixWithWhite(primary, 0.82, 0xFFEEEEEE),
      card: _mixWithWhite(primary, 0.86, 0xFFF0F0F0),
      icon: _dark(0xFF4A4A4A),
      text: _dark(0xFF1A1A1A),
      textSecondary: _dark(0xFF666666),
      divider: const Color(0xFFE3E3E3),
      gradient: [
        primary,
        primary,
        onAccent.withValues(alpha: 0.9),
      ],
    );
  }
}

Color _mixWithWhite(Color color, double white, int fallback) {
  final hsl = HSLColor.fromColor(color);
  final neutral = Color(fallback);
  return Color.lerp(hsl.withLightness(0.86).toColor(), neutral, white)!;
}

Color _dark(int value) => Color(value);

/// Chooses black or white as a readable foreground over [color].
Color _foregroundOn(Color color) =>
    color.computeLuminance() > 0.4 ? Colors.black : Colors.white;

const _spotifyGreen = Color(0xFF1DB954);
const _spotifyGreenBright = Color(0xFF1ED760);

/// The seven built-in palettes.
const List<ThemePalette> kThemePalettes = [
  ThemePalette(
    id: ThemePaletteId.spotifyGreen,
    name: 'Verde Spotify',
    primary: _spotifyGreen,
    secondary: _spotifyGreenBright,
    background: Color(0xFF121212),
    surface: Color(0xFF181818),
    surfaceHigh: Color(0xFF282828),
    card: Color(0xFF282828),
    icon: Color(0xFFFFFFFF),
    text: Color(0xFFE8E8E8),
    textSecondary: Color(0xFFB3B3B3),
    divider: Color(0xFFFFFFFF),
    gradient: [_spotifyGreen, _spotifyGreenBright, Color(0xFF0B5C33)],
  ),
  ThemePalette(
    id: ThemePaletteId.oceanBlue,
    name: 'Azul océano',
    primary: Color(0xFF2196F3),
    secondary: Color(0xFF00E5FF),
    background: Color(0xFF0B1220),
    surface: Color(0xFF101B2E),
    surfaceHigh: Color(0xFF1B2A44),
    card: Color(0xFF1B2A44),
    icon: Color(0xFFFFFFFF),
    text: Color(0xFFE8F0FB),
    textSecondary: Color(0xFF9FB4CE),
    divider: Color(0xFFFFFFFF),
    gradient: [Color(0xFF0277BD), Color(0xFF00B0FF), Color(0xFF00335E)],
  ),
  ThemePalette(
    id: ThemePaletteId.deepPurple,
    name: 'Púrpura profundo',
    primary: Color(0xFF7C4DFF),
    secondary: Color(0xFFB388FF),
    background: Color(0xFF120E1F),
    surface: Color(0xFF181229),
    surfaceHigh: Color(0xFF251B3D),
    card: Color(0xFF251B3D),
    icon: Color(0xFFFFFFFF),
    text: Color(0xFFEFE9FB),
    textSecondary: Color(0xFFB3A6D6),
    divider: Color(0xFFFFFFFF),
    gradient: [Color(0xFF7C4DFF), Color(0xFFB388FF), Color(0xFF2A1055)],
  ),
  ThemePalette(
    id: ThemePaletteId.sunsetOrange,
    name: 'Naranja atardecer',
    primary: Color(0xFFFF7043),
    secondary: Color(0xFFFFB300),
    background: Color(0xFF1F140F),
    surface: Color(0xFF291A12),
    surfaceHigh: Color(0xFF3D271B),
    card: Color(0xFF3D271B),
    icon: Color(0xFFFFFFFF),
    text: Color(0xFFFBF0EA),
    textSecondary: Color(0xFFD5B7A6),
    divider: Color(0xFFFFFFFF),
    gradient: [Color(0xFFF4511E), Color(0xFFFFA726), Color(0xFF57250A)],
  ),
  ThemePalette(
    id: ThemePaletteId.crimsonRed,
    name: 'Rojo carmesí',
    primary: Color(0xFFE53935),
    secondary: Color(0xFFFF6090),
    background: Color(0xFF1C1013),
    surface: Color(0xFF261417),
    surfaceHigh: Color(0xFF3B1F24),
    card: Color(0xFF3B1F24),
    icon: Color(0xFFFFFFFF),
    text: Color(0xFFFBE9EB),
    textSecondary: Color(0xFFD3A9AF),
    divider: Color(0xFFFFFFFF),
    gradient: [Color(0xFFC62828), Color(0xFFF06292), Color(0xFF4E0A0A)],
  ),
  ThemePalette(
    id: ThemePaletteId.monochrome,
    name: 'Monocromo',
    primary: Color(0xFFBDBDBD),
    secondary: Color(0xFF8A8A8A),
    background: Color(0xFF121212),
    surface: Color(0xFF181818),
    surfaceHigh: Color(0xFF262626),
    card: Color(0xFF262626),
    icon: Color(0xFFFFFFFF),
    text: Color(0xFFEDEDED),
    textSecondary: Color(0xFFA8A8A8),
    divider: Color(0xFFFFFFFF),
    gradient: [Color(0xFF757575), Color(0xFFBDBDBD), Color(0xFF212121)],
  ),
  ThemePalette(
    id: ThemePaletteId.amoledBlack,
    name: 'Negro AMOLED',
    primary: Color(0xFFF2F2F2),
    secondary: Color(0xFF9E9E9E),
    background: Color(0xFF000000),
    surface: Color(0xFF000000),
    surfaceHigh: Color(0xFF0D0D0D),
    card: Color(0xFF0D0D0D),
    icon: Color(0xFFFFFFFF),
    text: Color(0xFFF5F5F5),
    textSecondary: Color(0xFFA6A6A6),
    divider: Color(0xFFFFFFFF),
    gradient: [Color(0xFF333333), Color(0xFF8A8A8A), Color(0xFF000000)],
  ),
];

ThemePalette paletteById(ThemePaletteId id) =>
    kThemePalettes.firstWhere((p) => p.id == id);
