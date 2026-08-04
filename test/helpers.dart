import 'dart:async';

import 'package:musicallz/features/playlists/data/models/playlist.dart';
import 'package:musicallz/features/playlists/domain/repositories/favorites_repository.dart';
import 'package:musicallz/features/playlists/domain/repositories/playlist_repository.dart';

/// In-memory [PlaylistRepository] for widget tests. No native Isar needed.
class InMemoryPlaylistRepository implements PlaylistRepository {
  final _playlists = <Playlist>[];
  int _nextId = 1;
  final _changes = StreamController<void>.broadcast();

  void _notify() {
    if (!_changes.isClosed) _changes.add(null);
  }

  @override
  Stream<void> watchChanges() => _changes.stream;

  @override
  Future<Playlist> createPlaylist(
    String name, {
    String? description,
    List<String> songIds = const [],
  }) async {
    final now = DateTime.now();
    final playlist = Playlist()
      ..id = _nextId++
      ..name = name
      ..description = description
      ..createdAt = now
      ..updatedAt = now
      ..songIds = [...songIds];
    _playlists.add(playlist);
    _notify();
    return playlist;
  }

  @override
  Future<void> renamePlaylist(int id, String name) async {
    final p = _playlists.where((p) => p.id == id).firstOrNull;
    if (p == null) return;
    p.name = name;
    p.updatedAt = DateTime.now();
    _notify();
  }

  @override
  Future<void> updateDescription(int id, String? description) async {
    final p = _playlists.where((p) => p.id == id).firstOrNull;
    if (p == null) return;
    p.description =
        (description == null || description.isEmpty) ? null : description;
    p.updatedAt = DateTime.now();
    _notify();
  }

  @override
  Future<void> deletePlaylist(int id) async {
    _playlists.removeWhere((p) => p.id == id);
    _notify();
  }

  @override
  Future<void> addSong(int playlistId, String songId) async {
    final p = _playlists.where((p) => p.id == playlistId).firstOrNull;
    if (p == null || p.songIds.contains(songId)) return;
    p.songIds = [...p.songIds, songId];
    p.updatedAt = DateTime.now();
    _notify();
  }

  @override
  Future<void> removeSong(int playlistId, String songId) async {
    final p = _playlists.where((p) => p.id == playlistId).firstOrNull;
    if (p == null) return;
    p.songIds = p.songIds.where((id) => id != songId).toList();
    p.updatedAt = DateTime.now();
    _notify();
  }

  @override
  Future<void> moveSong(int playlistId, int from, int to) async {
    final p = _playlists.where((p) => p.id == playlistId).firstOrNull;
    if (p == null) return;
    final ids = [...p.songIds];
    if (from < 0 || from >= ids.length || to < 0 || to >= ids.length) return;
    final moved = ids.removeAt(from);
    ids.insert(to, moved);
    p.songIds = ids;
    p.updatedAt = DateTime.now();
    _notify();
  }

  @override
  Future<List<Playlist>> getAllPlaylists() async {
    final sorted = [..._playlists]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted;
  }

  @override
  Future<Playlist?> getPlaylist(int id) async =>
      _playlists.where((p) => p.id == id).firstOrNull;

  @override
  Future<int> songCount(int id) async =>
      _playlists.where((p) => p.id == id).firstOrNull?.songIds.length ?? 0;
}

/// In-memory [FavoritesRepository] for widget tests.
class InMemoryFavoritesRepository implements FavoritesRepository {
  final _ids = <String>[];
  final _changes = StreamController<void>.broadcast();

  void _notify() {
    if (!_changes.isClosed) _changes.add(null);
  }

  @override
  Stream<void> watchChanges() => _changes.stream;

  @override
  Future<void> addFavorite(String songId) async {
    if (_ids.contains(songId)) return;
    _ids.insert(0, songId);
    _notify();
  }

  @override
  Future<void> removeFavorite(String songId) async {
    _ids.remove(songId);
    _notify();
  }

  @override
  Future<bool> isFavoriteSong(String songId) async => _ids.contains(songId);

  @override
  Future<List<String>> getAllFavoriteSongIds() async => [..._ids];

  @override
  Future<void> toggle(String songId) async {
    if (_ids.contains(songId)) {
      await removeFavorite(songId);
    } else {
      await addFavorite(songId);
    }
  }
}