import '../../data/models/playlist.dart';

/// Contract for the playlists persistence layer.
abstract class PlaylistRepository {
  Future<Playlist> createPlaylist(
    String name, {
    String? description,
    List<String> songIds = const [],
  });

  Future<void> renamePlaylist(int id, String name);

  Future<void> updateDescription(int id, String? description);

  Future<void> deletePlaylist(int id);

  Future<void> addSong(int playlistId, String songId);

  Future<void> removeSong(int playlistId, String songId);

  Future<void> moveSong(int playlistId, int from, int to);

  Future<List<Playlist>> getAllPlaylists();

  Future<Playlist?> getPlaylist(int id);

  Future<int> songCount(int id);

  /// Emits whenever any playlist is written, so reactive providers can
  /// re-read the collection.
  Stream<void> watchChanges();
}