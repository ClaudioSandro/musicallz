import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../library/domain/entities/song.dart';
import '../../../library/presentation/providers/music_library_provider.dart';
import '../../data/models/playlist.dart';
import '../../data/repositories/isar_favorites_repository.dart';
import '../../data/repositories/isar_playlist_repository.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../domain/repositories/playlist_repository.dart';

/// Overridden in `main()` with the Isar instance opened before `runApp`.
final isarProvider = Provider<Isar>(
  (_) => throw UnimplementedError('isarProvider must be overridden in main()'),
);

final playlistRepositoryProvider = Provider<PlaylistRepository>(
  (ref) => IsarPlaylistRepository(ref.watch(isarProvider)),
);

final favoritesRepositoryProvider = Provider<FavoritesRepository>(
  (ref) => IsarFavoritesRepository(ref.watch(isarProvider)),
);

/// All playlists (sorted by most recently updated). Re-emits whenever the
/// underlying Isar collection changes, so consumers update reactively.
final playlistsProvider = StreamProvider<List<Playlist>>((ref) {
  final repo = ref.watch(playlistRepositoryProvider);
  final controller = StreamController<List<Playlist>>();
  Future<void> refresh() async {
    if (controller.isClosed) return;
    try {
      controller.add(await repo.getAllPlaylists());
    } catch (error, stackTrace) {
      controller.addError(error, stackTrace);
    }
  }

  final sub = repo.watchChanges().listen((_) => refresh());
  refresh();
  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });
  return controller.stream;
});

/// One playlist by id, resolved from [playlistsProvider] so it stays reactive.
final playlistProvider = Provider.family<Playlist?, int>((ref, id) {
  final all = ref.watch(playlistsProvider).valueOrNull ?? const [];
  for (final playlist in all) {
    if (playlist.id == id) return playlist;
  }
  return null;
});

/// Favorite song ids (most recently added first), reactive to DB changes.
final favoriteSongIdsProvider = StreamProvider<List<String>>((ref) {
  final repo = ref.watch(favoritesRepositoryProvider);
  final controller = StreamController<List<String>>();
  Future<void> refresh() async {
    if (controller.isClosed) return;
    try {
      controller.add(await repo.getAllFavoriteSongIds());
    } catch (error, stackTrace) {
      controller.addError(error, stackTrace);
    }
  }

  final sub = repo.watchChanges().listen((_) => refresh());
  refresh();
  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });
  return controller.stream;
});

/// Whether a given song is currently a favorite.
final isFavoriteProvider = Provider.family<bool, String>((ref, songId) {
  final ids = ref.watch(favoriteSongIdsProvider).valueOrNull ?? const [];
  return ids.contains(songId);
});

/// id -> Song map built from the scanned local library.
final songByIdProvider = Provider<Map<String, Song>>((ref) {
  final songs = ref.watch(musicLibraryProvider).valueOrNull ?? const [];
  return {for (final song in songs) song.id: song};
});

/// Resolves a list of song ids into [Song] objects, skipping ids that are no
/// longer present in the local library.
final songsByIdProvider = Provider.family<List<Song>, List<String>>((ref, ids) {
  final map = ref.watch(songByIdProvider);
  return [for (final id in ids) if (map.containsKey(id)) map[id]!];
});

/// Full list of favorite songs in most-recently-added order.
final likedSongsProvider = Provider<List<Song>>((ref) {
  final ids = ref.watch(favoriteSongIdsProvider).valueOrNull ?? const [];
  return ref.watch(songsByIdProvider(ids));
});