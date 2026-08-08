import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme_models.dart';

/// Persists the appearance preferences using SharedPreferences.
class ThemeRepository {
  static const _kMode = 'theme_mode';
  static const _kPalette = 'theme_palette';
  static const _kBackgroundStyle = 'theme_background_style';
  static const _kIntensity = 'theme_intensity';

  ThemeState read(SharedPreferences prefs) {
    T readEnum<T extends Enum>(List<T> values, String key, T fallback) {
      final name = prefs.getString(key);
      if (name == null) return fallback;
      for (final value in values) {
        if (value.name == name) return value;
      }
      return fallback;
    }

    return ThemeState(
      mode: readEnum(
        ThemeModeOption.values,
        _kMode,
        ThemeModeOption.dark,
      ),
      palette: readEnum(
        ThemePaletteId.values,
        _kPalette,
        ThemePaletteId.spotifyGreen,
      ),
      backgroundStyle: readEnum(
        BackgroundStyle.values,
        _kBackgroundStyle,
        BackgroundStyle.gradient,
      ),
      intensity: readEnum(
        BackgroundIntensity.values,
        _kIntensity,
        BackgroundIntensity.medium,
      ),
    );
  }

  Future<void> write(SharedPreferences prefs, ThemeState state) async {
    await prefs.setString(_kMode, state.mode.name);
    await prefs.setString(_kPalette, state.palette.name);
    await prefs.setString(_kBackgroundStyle, state.backgroundStyle.name);
    await prefs.setString(_kIntensity, state.intensity.name);
  }
}

final themeRepositoryProvider = Provider<ThemeRepository>((ref) {
  return ThemeRepository();
});
