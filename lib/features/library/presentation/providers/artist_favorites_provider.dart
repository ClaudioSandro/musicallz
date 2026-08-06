import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Set of artist ids followed by the user, persisted in SharedPreferences so
/// the artist detail header can show a working Follow button.
final artistFavoritesProvider =
    NotifierProvider<ArtistFavoritesNotifier, Set<String>>(
  ArtistFavoritesNotifier.new,
);

class ArtistFavoritesNotifier extends Notifier<Set<String>> {
  static const _kKey = 'followed_artists';
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

  bool isFollowed(String artistId) => state.contains(artistId);

  Future<void> toggle(String artistId) async {
    final next = {...state};
    if (!next.add(artistId)) next.remove(artistId);
    state = UnmodifiableSetView(next);
    try {
      final prefs = _prefs ??= await SharedPreferences.getInstance();
      await prefs.setStringList(_kKey, next.toList());
    } catch (_) {
      // Best effort.
    }
  }
}
