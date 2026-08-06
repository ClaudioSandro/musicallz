import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Set of album ids marked as saved by the user, persisted in
/// SharedPreferences so the album detail header can show a working
/// Favorite/Saved button.
final albumFavoritesProvider =
    NotifierProvider<AlbumFavoritesNotifier, Set<String>>(
  AlbumFavoritesNotifier.new,
);

class AlbumFavoritesNotifier extends Notifier<Set<String>> {
  static const _kKey = 'saved_albums';
  SharedPreferences? _prefs;
  bool _disposed = false;

  @override
  Set<String> build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    _load();
    return <String>{};
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_disposed) return;
      _prefs = prefs;
      final stored = prefs.getStringList(_kKey) ?? const <String>[];
      state = UnmodifiableSetView(stored.toSet());
    } catch (_) {
      // No platform store (tests) -> keep empty.
    }
  }

  bool isSaved(String albumId) => state.contains(albumId);

  Future<void> toggle(String albumId) async {
    final next = {...state};
    if (!next.add(albumId)) next.remove(albumId);
    state = UnmodifiableSetView(next);
    try {
      final prefs = _prefs ??= await SharedPreferences.getInstance();
      await prefs.setStringList(_kKey, next.toList());
    } catch (_) {
      // Best effort.
    }
  }
}
