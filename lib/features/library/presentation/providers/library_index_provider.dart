import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/album.dart';
import '../../domain/entities/artist.dart';
import '../../domain/entities/song.dart';
import '../../domain/services/library_index.dart';
import 'music_library_provider.dart';

/// Builds (and memoizes) the library indexes from the scanned songs.
/// Recomputes only when the underlying song list changes.
final libraryIndexProvider = Provider<LibraryIndex?>((ref) {
  final songs = ref.watch(musicLibraryProvider).valueOrNull;
  if (songs == null) return null;
  return LibraryIndex.fromSongs(songs);
});

final artistsProvider = Provider<List<Artist>>(
  (ref) => ref.watch(libraryIndexProvider)?.artists ?? const [],
);

final albumsProvider = Provider<List<Album>>(
  (ref) => ref.watch(libraryIndexProvider)?.albums ?? const [],
);

/// Songs ordered by first-seen date (newest first).
final recentlyAddedProvider = Provider<List<Song>>(
  (ref) => ref.watch(libraryIndexProvider)?.recentlyAdded ?? const [],
);

final artistProvider = Provider.family<Artist?, String>(
  (ref, artistId) {
    final artists = ref.watch(artistsProvider);
    for (final artist in artists) {
      if (artist.id == artistId) return artist;
    }
    return null;
  },
);

final albumProvider = Provider.family<Album?, String>(
  (ref, albumId) {
    final albums = ref.watch(albumsProvider);
    for (final album in albums) {
      if (album.id == albumId) return album;
    }
    return null;
  },
);

final artistSongsProvider = Provider.family<List<Song>, String>(
  (ref, artistId) =>
      ref.watch(libraryIndexProvider)?.songsForArtist(artistId) ?? const [],
);

final albumSongsProvider = Provider.family<List<Song>, String>(
  (ref, albumId) =>
      ref.watch(libraryIndexProvider)?.songsForAlbum(albumId) ?? const [],
);

final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = Provider<SearchResults>((ref) {
  final index = ref.watch(libraryIndexProvider);
  final query = ref.watch(searchQueryProvider);
  if (index == null) return const SearchResults.empty();
  return index.search(query);
});