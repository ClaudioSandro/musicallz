import 'package:isar/isar.dart';

import '../../domain/repositories/playlist_repository.dart';
import '../models/playlist.dart';

/// [PlaylistRepository] implemented on top of Isar.
class IsarPlaylistRepository implements PlaylistRepository {
  IsarPlaylistRepository(this._isar);

  final Isar _isar;

  @override
  Future<Playlist> createPlaylist(
    String name, {
    String? description,
    List<String> songIds = const [],
  }) {
    final now = DateTime.now();
    final playlist = Playlist()
      ..name = name.trim()
      ..description = description?.trim()
      ..createdAt = now
      ..updatedAt = now
      ..songIds = List<String>.from(songIds);
    return _isar.writeTxn(() async {
      await _isar.playlists.put(playlist);
      return playlist;
    });
  }

  @override
  Future<void> renamePlaylist(int id, String name) {
    return _isar.writeTxn(() async {
      final playlist = await _isar.playlists.get(id);
      if (playlist == null) return;
      playlist.name = name.trim();
      playlist.updatedAt = DateTime.now();
      await _isar.playlists.put(playlist);
    });
  }

  @override
  Future<void> updateDescription(int id, String? description) {
    return _isar.writeTxn(() async {
      final playlist = await _isar.playlists.get(id);
      if (playlist == null) return;
      playlist.description =
          (description == null || description.trim().isEmpty)
              ? null
              : description.trim();
      playlist.updatedAt = DateTime.now();
      await _isar.playlists.put(playlist);
    });
  }

  @override
  Future<void> deletePlaylist(int id) {
    return _isar.writeTxn(() async {
      await _isar.playlists.delete(id);
    });
  }

  @override
  Future<void> addSong(int playlistId, String songId) {
    return _isar.writeTxn(() async {
      final playlist = await _isar.playlists.get(playlistId);
      if (playlist == null || playlist.songIds.contains(songId)) return;
      playlist.songIds = [...playlist.songIds, songId];
      playlist.updatedAt = DateTime.now();
      await _isar.playlists.put(playlist);
    });
  }

  @override
  Future<void> removeSong(int playlistId, String songId) {
    return _isar.writeTxn(() async {
      final playlist = await _isar.playlists.get(playlistId);
      if (playlist == null) return;
      playlist.songIds =
          playlist.songIds.where((id) => id != songId).toList();
      playlist.updatedAt = DateTime.now();
      await _isar.playlists.put(playlist);
    });
  }

  @override
  Future<void> moveSong(int playlistId, int from, int to) {
    return _isar.writeTxn(() async {
      final playlist = await _isar.playlists.get(playlistId);
      if (playlist == null) return;
      final ids = List<String>.from(playlist.songIds);
      if (from < 0 || from >= ids.length || to < 0 || to >= ids.length) return;
      final moved = ids.removeAt(from);
      ids.insert(to, moved);
      playlist.songIds = ids;
      playlist.updatedAt = DateTime.now();
      await _isar.playlists.put(playlist);
    });
  }

  @override
  Future<List<Playlist>> getAllPlaylists() {
    return _isar.playlists.where().sortByUpdatedAtDesc().findAll();
  }

  @override
  Future<Playlist?> getPlaylist(int id) => _isar.playlists.get(id);

  @override
  Future<int> songCount(int id) async {
    final playlist = await _isar.playlists.get(id);
    return playlist?.songIds.length ?? 0;
  }

  @override
  Stream<void> watchChanges() => _isar.playlists.watchLazy();
}