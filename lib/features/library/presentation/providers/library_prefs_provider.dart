import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../features/playlists/domain/services/playlist_sort.dart';
import '../../domain/services/library_index.dart';

/// Layout variants for the Songs tab.
enum SongsView { list, compact }

/// Layout variants for the Albums tab.
enum AlbumsView { grid2, grid3 }

/// Layout variants for the Artists tab.
enum ArtistsView { list, grid2 }

/// Layout variants for the Playlists tab.
enum PlaylistsView { list, grid2 }

/// Persisted per-section presentation preferences (sorting + view mode).
class LibraryPrefs {
  const LibraryPrefs({
    required this.songsSort,
    required this.albumsSort,
    required this.artistsSort,
    required this.playlistsSort,
    required this.likedSort,
    required this.songsView,
    required this.albumsView,
    required this.artistsView,
    required this.playlistsView,
  });

  const LibraryPrefs.defaults()
      : songsSort = SongsSort.titleAsc,
        albumsSort = AlbumsSort.titleAsc,
        artistsSort = ArtistsSort.nameAsc,
        playlistsSort = PlaylistsSort.updatedNew,
        likedSort = SongsSort.addedNew,
        songsView = SongsView.list,
        albumsView = AlbumsView.grid2,
        artistsView = ArtistsView.list,
        playlistsView = PlaylistsView.list;

  final SongsSort songsSort;
  final AlbumsSort albumsSort;
  final ArtistsSort artistsSort;
  final PlaylistsSort playlistsSort;
  final SongsSort likedSort;
  final SongsView songsView;
  final AlbumsView albumsView;
  final ArtistsView artistsView;
  final PlaylistsView playlistsView;

  LibraryPrefs copyWith({
    SongsSort? songsSort,
    AlbumsSort? albumsSort,
    ArtistsSort? artistsSort,
    PlaylistsSort? playlistsSort,
    SongsSort? likedSort,
    SongsView? songsView,
    AlbumsView? albumsView,
    ArtistsView? artistsView,
    PlaylistsView? playlistsView,
  }) {
    return LibraryPrefs(
      songsSort: songsSort ?? this.songsSort,
      albumsSort: albumsSort ?? this.albumsSort,
      artistsSort: artistsSort ?? this.artistsSort,
      playlistsSort: playlistsSort ?? this.playlistsSort,
      likedSort: likedSort ?? this.likedSort,
      songsView: songsView ?? this.songsView,
      albumsView: albumsView ?? this.albumsView,
      artistsView: artistsView ?? this.artistsView,
      playlistsView: playlistsView ?? this.playlistsView,
    );
  }

  factory LibraryPrefs.fromPrefs(SharedPreferences prefs) {
    T readEnum<T extends Enum>(List<T> values, String key, T fallback) {
      final name = prefs.getString(key);
      if (name == null) return fallback;
      for (final value in values) {
        if (value.name == name) return value;
      }
      return fallback;
    }

    return LibraryPrefs(
      songsSort:
          readEnum(SongsSort.values, _kSongsSort, SongsSort.titleAsc),
      albumsSort:
          readEnum(AlbumsSort.values, _kAlbumsSort, AlbumsSort.titleAsc),
      artistsSort:
          readEnum(ArtistsSort.values, _kArtistsSort, ArtistsSort.nameAsc),
      playlistsSort: readEnum(
          PlaylistsSort.values, _kPlaylistsSort, PlaylistsSort.updatedNew),
      likedSort:
          readEnum(SongsSort.values, _kLikedSort, SongsSort.addedNew),
      songsView:
          readEnum(SongsView.values, _kSongsView, SongsView.list),
      albumsView:
          readEnum(AlbumsView.values, _kAlbumsView, AlbumsView.grid2),
      artistsView:
          readEnum(ArtistsView.values, _kArtistsView, ArtistsView.list),
      playlistsView: readEnum(
          PlaylistsView.values, _kPlaylistsView, PlaylistsView.list),
    );
  }

  static const _kSongsSort = 'songs_sort';
  static const _kAlbumsSort = 'albums_sort';
  static const _kArtistsSort = 'artists_sort';
  static const _kPlaylistsSort = 'playlists_sort';
  static const _kLikedSort = 'liked_sort';
  static const _kSongsView = 'songs_view';
  static const _kAlbumsView = 'albums_view';
  static const _kArtistsView = 'artists_view';
  static const _kPlaylistsView = 'playlists_view';
}

/// Loads [LibraryPrefs] from SharedPreferences asynchronously and exposes
/// setters that persist each change. Falls back to defaults when the platform
/// store is unavailable (e.g. in tests).
class LibraryPrefsNotifier extends Notifier<LibraryPrefs> {
  SharedPreferences? _prefs;
  bool _disposed = false;

  @override
  LibraryPrefs build() {
    _disposed = false;
    ref.onDispose(() => _disposed = true);
    _load();
    return const LibraryPrefs.defaults();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_disposed) return;
      _prefs = prefs;
      state = LibraryPrefs.fromPrefs(prefs);
    } catch (_) {
      // No platform store (tests) -> keep defaults.
    }
  }

  void _save(String key, String value) {
    _prefs?.setString(key, value);
  }

  void setSongsSort(SongsSort value) {
    state = state.copyWith(songsSort: value);
    _save(LibraryPrefs._kSongsSort, value.name);
  }

  void setAlbumsSort(AlbumsSort value) {
    state = state.copyWith(albumsSort: value);
    _save(LibraryPrefs._kAlbumsSort, value.name);
  }

  void setArtistsSort(ArtistsSort value) {
    state = state.copyWith(artistsSort: value);
    _save(LibraryPrefs._kArtistsSort, value.name);
  }

  void setPlaylistsSort(PlaylistsSort value) {
    state = state.copyWith(playlistsSort: value);
    _save(LibraryPrefs._kPlaylistsSort, value.name);
  }

  void setLikedSort(SongsSort value) {
    state = state.copyWith(likedSort: value);
    _save(LibraryPrefs._kLikedSort, value.name);
  }

  void setSongsView(SongsView value) {
    state = state.copyWith(songsView: value);
    _save(LibraryPrefs._kSongsView, value.name);
  }

  void setAlbumsView(AlbumsView value) {
    state = state.copyWith(albumsView: value);
    _save(LibraryPrefs._kAlbumsView, value.name);
  }

  void setArtistsView(ArtistsView value) {
    state = state.copyWith(artistsView: value);
    _save(LibraryPrefs._kArtistsView, value.name);
  }

  void setPlaylistsView(PlaylistsView value) {
    state = state.copyWith(playlistsView: value);
    _save(LibraryPrefs._kPlaylistsView, value.name);
  }
}

final libraryPrefsProvider =
    NotifierProvider<LibraryPrefsNotifier, LibraryPrefs>(
  LibraryPrefsNotifier.new,
);
