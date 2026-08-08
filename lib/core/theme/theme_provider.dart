import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme_models.dart';
import 'theme_repository.dart';

/// Holds the current [ThemeState], persists every change and exposes the
/// setters used by the Appearance screen.
///
/// Starts with the default state (dark Spotify) so the first frame is correct,
/// then asynchronously loads the saved preferences and replaces the state.
class ThemeController extends Notifier<ThemeState> {
  SharedPreferences? _prefs;
  bool _disposed = false;

  @override
  ThemeState build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    _load();
    return const ThemeState();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_disposed) return;
      _prefs = prefs;
      state = ref.read(themeRepositoryProvider).read(prefs);
    } catch (_) {
      // No platform store (e.g. widget tests) -> keep defaults.
    }
  }

  void setMode(ThemeModeOption value) => _update(state.copyWith(mode: value));

  void setPalette(ThemePaletteId value) =>
      _update(state.copyWith(palette: value));

  void setBackgroundStyle(BackgroundStyle value) =>
      _update(state.copyWith(backgroundStyle: value));

  void setIntensity(BackgroundIntensity value) =>
      _update(state.copyWith(intensity: value));

  void _update(ThemeState next) {
    state = next;
    final prefs = _prefs;
    if (prefs == null) return;
    ref.read(themeRepositoryProvider).write(prefs, next);
  }
}

final themeControllerProvider =
    NotifierProvider<ThemeController, ThemeState>(ThemeController.new);
