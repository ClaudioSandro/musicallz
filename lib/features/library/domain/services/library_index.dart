import 'dart:typed_data';

import '../entities/album.dart';
import '../entities/artist.dart';
import '../entities/song.dart';

class LibraryIndex {
  LibraryIndex._({
    required this.songs,
    required this.artists,
    required this.albums,
    required Map<String, List<Song>> songsByArtist,
    required Map<String, List<Song>> songsByAlbum,
  })  : _songsByArtist = songsByArtist,
        _songsByAlbum = songsByAlbum;

  factory LibraryIndex.fromSongs(List<Song> input) {
    final songs = [...input]..sort((a, b) => _compare(a.title, b.title));

    final artistGroups = _groupBy(input, (s) => _key(s.artist));
    final artists = artistGroups.values.map((group) {
      final groupedSongs = [...group]..sort(_byAlbumThenTrack);
      final albumCount = groupedSongs.map((s) => _key(s.album)).toSet().length;
      final name = group.first.artist;
      return Artist(
        id: _key(name),
        name: name,
        songCount: groupedSongs.length,
        albumCount: albumCount,
        songs: groupedSongs,
        coverArt: _firstArt(groupedSongs),
      );
    }).toList()
      ..sort((a, b) => _compare(a.name, b.name));

    final albumGroups =
        _groupBy(input, (s) => '${_key(s.artist)}::${_key(s.album)}');
    final albums = albumGroups.values.map((group) {
      final groupedSongs = [...group]..sort(_byTrackThenTitle);
      int? year;
      for (final s in groupedSongs) {
        if (s.year != null) {
          year = s.year;
          break;
        }
      }
      final title = group.first.album;
      final artist = group.first.artist;
      return Album(
        id: '${_key(artist)}::${_key(title)}',
        title: title,
        artist: artist,
        songCount: groupedSongs.length,
        year: year,
        songs: groupedSongs,
        coverArt: _firstArt(groupedSongs),
      );
    }).toList()
      ..sort((a, b) => _compare(a.title, b.title));

    final byArtist = <String, List<Song>>{
      for (final a in artists) a.id: a.songs,
    };
    final byAlbum = <String, List<Song>>{
      for (final a in albums) a.id: a.songs,
    };

    return LibraryIndex._(
      songs: songs,
      artists: artists,
      albums: albums,
      songsByArtist: byArtist,
      songsByAlbum: byAlbum,
    );
  }

  final List<Song> songs;
  final List<Artist> artists;
  final List<Album> albums;
  final Map<String, List<Song>> _songsByArtist;
  final Map<String, List<Song>> _songsByAlbum;

  List<Song> songsForArtist(String artistId) =>
      _songsByArtist[artistId] ?? const [];

  List<Song> songsForAlbum(String albumId) =>
      _songsByAlbum[albumId] ?? const [];

  SearchResults search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const SearchResults.empty();
    return SearchResults(
      songs: songs
          .where((s) =>
              s.title.toLowerCase().contains(q) ||
              s.artist.toLowerCase().contains(q) ||
              s.album.toLowerCase().contains(q))
          .toList(),
      artists:
          artists.where((a) => a.name.toLowerCase().contains(q)).toList(),
      albums: albums
          .where((a) =>
              a.title.toLowerCase().contains(q) ||
              a.artist.toLowerCase().contains(q))
          .toList(),
    );
  }

  static Map<String, List<Song>> _groupBy(
    Iterable<Song> songs,
    String Function(Song) keyOf,
  ) {
    final map = <String, List<Song>>{};
    for (final s in songs) {
      map.putIfAbsent(keyOf(s), () => []).add(s);
    }
    return map;
  }

  static String _key(String value) => value.trim().toLowerCase();

  static int _compare(String a, String b) => _key(a).compareTo(_key(b));

  static int _byAlbumThenTrack(Song a, Song b) {
    final album = _compare(a.album, b.album);
    if (album != 0) return album;
    final at = a.trackNumber ?? -1;
    final bt = b.trackNumber ?? -1;
    if (at != bt) return at.compareTo(bt);
    return _compare(a.title, b.title);
  }

  static int _byTrackThenTitle(Song a, Song b) {
    final at = a.trackNumber ?? -1;
    final bt = b.trackNumber ?? -1;
    if (at != bt) return at.compareTo(bt);
    return _compare(a.title, b.title);
  }

  static Uint8List? _firstArt(List<Song> songs) {
    for (final s in songs) {
      if (s.albumArt != null) return s.albumArt;
    }
    return null;
  }
}

class SearchResults {
  const SearchResults({
    required this.songs,
    required this.artists,
    required this.albums,
  });

  const SearchResults.empty()
      : songs = const [],
        artists = const [],
        albums = const [];

  final List<Song> songs;
  final List<Artist> artists;
  final List<Album> albums;

  bool get isEmpty => songs.isEmpty && artists.isEmpty && albums.isEmpty;
}