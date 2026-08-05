import 'dart:typed_data';

import '../entities/album.dart';
import '../entities/artist.dart';
import '../entities/song.dart';

/// How the Songs tab can be ordered.
enum SongsSort {
  titleAsc,
  titleDesc,
  artistAsc,
  albumAsc,
  addedNew,
  addedOld,
  modifiedNew,
  modifiedOld,
  yearNew,
  yearOld,
  durationLong,
  durationShort,
  mostPlayed,
}

/// How the Albums tab can be ordered.
enum AlbumsSort {
  titleAsc,
  titleDesc,
  artistAsc,
  yearNew,
  yearOld,
  songCount,
  mostPlayed,
}

/// How the Artists tab can be ordered.
enum ArtistsSort {
  nameAsc,
  nameDesc,
  songCount,
  albumCount,
  mostPlayed,
}

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

    // One entry per artist name: a song that lists several artists (e.g.
    // "Aimer feat. LiSA") appears under every one of them.
    final artistGroups = <String, List<Song>>{};
    for (final s in input) {
      for (final name in s.artists) {
        artistGroups.putIfAbsent(_key(name), () => []).add(s);
      }
    }
    final artists = artistGroups.entries.map((entry) {
      final groupedSongs = [...entry.value]..sort(_byAlbumThenTrack);
      final albumCount = groupedSongs.map(_albumKey).toSet().length;
      final name = groupedSongs
          .expand((s) => s.artists)
          .firstWhere((n) => _key(n) == entry.key, orElse: () => entry.key);
      return Artist(
        id: entry.key,
        name: name,
        songCount: groupedSongs.length,
        albumCount: albumCount,
        songs: groupedSongs,
        playCount:
            groupedSongs.fold<int>(0, (sum, s) => sum + s.playCount),
        coverArt: _firstArt(groupedSongs),
        coverArtPath: _firstArtPath(groupedSongs),
      );
    }).toList()
      ..sort((a, b) => _compare(a.name, b.name));

    // Albums are attributed to the album artist when present, otherwise to the
    // track's primary artist, so a collaborative song lands on the album of
    // the main artist instead of spawning one album per collaborator.
    final albumGroups = _groupBy(input, (s) => _albumKey(s));
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
      final artist = _albumArtist(group.first);
      return Album(
        id: _albumKey(group.first),
        title: title,
        artist: artist,
        songCount: groupedSongs.length,
        year: year,
        songs: groupedSongs,
        coverArt: _firstArt(groupedSongs),
        coverArtPath: _firstArtPath(groupedSongs),
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

  /// Artists ranked by total play count (then song count, then name). Powers
  /// the Home "Top Artists" row.
  List<Artist> get topArtists {
    final ranked = [...artists]..sort((a, b) {
        if (a.playCount != b.playCount) {
          return b.playCount.compareTo(a.playCount);
        }
        if (a.songCount != b.songCount) {
          return b.songCount.compareTo(a.songCount);
        }
        return _compare(a.name, b.name);
      });
    return ranked;
  }

  /// Songs ordered by real file date (newest first), falling back to the
  /// first-seen date when the file date is missing. Powers Home
  /// "Recently Added".
  List<Song> get recentlyAdded {
    final sorted = [...songs]..sort((a, b) {
        final at = a.modifiedAt ?? a.addedAt;
        final bt = b.modifiedAt ?? b.addedAt;
        if (at == null && bt == null) return 0;
        if (at == null) return 1;
        if (bt == null) return -1;
        return bt.compareTo(at);
      });
    return sorted;
  }

  /// All distinct genres in the library (case-insensitive), alphabetically
  /// ordered. Keeps the casing of the first song that introduced the genre.
  List<String> get genres {
    final byKey = <String, String>{};
    for (final s in songs) {
      final g = s.genre?.trim();
      if (g != null && g.isNotEmpty) {
        byKey.putIfAbsent(g.toLowerCase(), () => g);
      }
    }
    final list = byKey.values.toList()..sort(_compare);
    return list;
  }

  List<Song> sortedSongs(SongsSort sort) => sortSongs(songs, sort);

  List<Album> sortedAlbums(AlbumsSort sort) => sortAlbums(albums, sort);

  List<Artist> sortedArtists(ArtistsSort sort) => sortArtists(artists, sort);

  List<Song> songsForArtist(String artistId) =>
      _songsByArtist[artistId] ?? const [];

  List<Song> songsForAlbum(String albumId) =>
      _songsByAlbum[albumId] ?? const [];

  /// Albums that contain at least one song by [artistId]. Unlike matching by
  /// display name, this stays correct when the album is attributed to a
  /// different (album) artist.
  List<Album> albumsForArtist(String artistId) {
    final artistSongs = _songsByArtist[artistId];
    if (artistSongs == null || artistSongs.isEmpty) return const [];
    final songIds = artistSongs.map((s) => s.id).toSet();
    return albums
        .where((a) => a.songs.any((s) => songIds.contains(s.id)))
        .toList();
  }

  List<Song> songsForGenre(String genre) {
    final g = genre.trim().toLowerCase();
    if (g.isEmpty) return const [];
    return songs
        .where((s) =>
            s.genre != null && s.genre!.trim().toLowerCase() == g)
        .toList();
  }

  List<Album> albumsForGenre(String genre) {
    final songIds = songsForGenre(genre).map((s) => s.id).toSet();
    if (songIds.isEmpty) return const [];
    return albums
        .where((a) => a.songs.any((s) => songIds.contains(s.id)))
        .toList();
  }

  List<Artist> artistsForGenre(String genre) {
    final songIds = songsForGenre(genre).map((s) => s.id).toSet();
    if (songIds.isEmpty) return const [];
    return artists
        .where((a) => a.songs.any((s) => songIds.contains(s.id)))
        .toList();
  }

  SearchResults search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const SearchResults.empty();
    return SearchResults(
      songs: songs
          .where((s) =>
              s.title.toLowerCase().contains(q) ||
              s.artist.toLowerCase().contains(q) ||
              s.album.toLowerCase().contains(q) ||
              (s.genre?.toLowerCase().contains(q) ?? false) ||
              (s.composer?.toLowerCase().contains(q) ?? false))
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

  static String _albumArtist(Song s) {
    final albumArtist = s.albumArtist;
    if (albumArtist != null && albumArtist.trim().isNotEmpty) {
      return albumArtist.trim();
    }
    return s.primaryArtist;
  }

  static String _albumKey(Song s) =>
      '${_key(_albumArtist(s))}::${_key(s.album)}';

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

  static String? _firstArtPath(List<Song> songs) {
    for (final s in songs) {
      if (s.albumArtPath != null) return s.albumArtPath;
    }
    return null;
  }
}

String _key(String value) => value.trim().toLowerCase();

int _compare(String a, String b) => _key(a).compareTo(_key(b));

int _byDateDesc(DateTime? a, DateTime? b) {
  if (a == null && b == null) return 0;
  if (a == null) return 1;
  if (b == null) return -1;
  return b.compareTo(a);
}

int _byDateAsc(DateTime? a, DateTime? b) => -_byDateDesc(a, b);

int _byIntDesc(int? a, int? b) {
  if (a == null && b == null) return 0;
  if (a == null) return 1;
  if (b == null) return -1;
  return b.compareTo(a);
}

int _byIntAsc(int? a, int? b) => -_byIntDesc(a, b);

/// Orders [input] songs according to [sort]. Standalone so lists built outside
/// the index (e.g. Liked Songs) share the same comparators.
List<Song> sortSongs(List<Song> input, SongsSort sort) {
  final sorted = [...input];
  switch (sort) {
    case SongsSort.titleAsc:
      sorted.sort((a, b) => _compare(a.title, b.title));
    case SongsSort.titleDesc:
      sorted.sort((a, b) => _compare(b.title, a.title));
    case SongsSort.artistAsc:
      sorted.sort((a, b) {
        final c = _compare(a.artist, b.artist);
        return c != 0 ? c : _compare(a.title, b.title);
      });
    case SongsSort.albumAsc:
      sorted.sort((a, b) {
        final c = _compare(a.album, b.album);
        return c != 0 ? c : _compare(a.title, b.title);
      });
    case SongsSort.addedNew:
      sorted.sort((a, b) => _byDateDesc(a.addedAt, b.addedAt));
    case SongsSort.addedOld:
      sorted.sort((a, b) => _byDateAsc(a.addedAt, b.addedAt));
    case SongsSort.modifiedNew:
      sorted.sort((a, b) {
        final at = a.modifiedAt ?? a.addedAt;
        final bt = b.modifiedAt ?? b.addedAt;
        return _byDateDesc(at, bt);
      });
    case SongsSort.modifiedOld:
      sorted.sort((a, b) {
        final at = a.modifiedAt ?? a.addedAt;
        final bt = b.modifiedAt ?? b.addedAt;
        return _byDateAsc(at, bt);
      });
    case SongsSort.yearNew:
      sorted.sort((a, b) => _byIntDesc(a.year, b.year));
    case SongsSort.yearOld:
      sorted.sort((a, b) => _byIntAsc(a.year, b.year));
    case SongsSort.durationLong:
      sorted.sort((a, b) => b.duration.compareTo(a.duration));
    case SongsSort.durationShort:
      sorted.sort((a, b) => a.duration.compareTo(b.duration));
    case SongsSort.mostPlayed:
      sorted.sort((a, b) {
        if (a.playCount != b.playCount) {
          return b.playCount.compareTo(a.playCount);
        }
        return _compare(a.title, b.title);
      });
  }
  return sorted;
}

/// Orders [input] albums according to [sort].
List<Album> sortAlbums(List<Album> input, AlbumsSort sort) {
  final sorted = [...input];
  switch (sort) {
    case AlbumsSort.titleAsc:
      sorted.sort((a, b) => _compare(a.title, b.title));
    case AlbumsSort.titleDesc:
      sorted.sort((a, b) => _compare(b.title, a.title));
    case AlbumsSort.artistAsc:
      sorted.sort((a, b) {
        final c = _compare(a.artist, b.artist);
        return c != 0 ? c : _compare(a.title, b.title);
      });
    case AlbumsSort.yearNew:
      sorted.sort((a, b) => _byIntDesc(a.year, b.year));
    case AlbumsSort.yearOld:
      sorted.sort((a, b) => _byIntAsc(a.year, b.year));
    case AlbumsSort.songCount:
      sorted.sort((a, b) {
        if (a.songCount != b.songCount) {
          return b.songCount.compareTo(a.songCount);
        }
        return _compare(a.title, b.title);
      });
    case AlbumsSort.mostPlayed:
      sorted.sort((a, b) {
        final pa = a.songs.fold<int>(0, (sum, s) => sum + s.playCount);
        final pb = b.songs.fold<int>(0, (sum, s) => sum + s.playCount);
        if (pa != pb) return pb.compareTo(pa);
        return _compare(a.title, b.title);
      });
  }
  return sorted;
}

/// Orders [input] artists according to [sort].
List<Artist> sortArtists(List<Artist> input, ArtistsSort sort) {
  final sorted = [...input];
  switch (sort) {
    case ArtistsSort.nameAsc:
      sorted.sort((a, b) => _compare(a.name, b.name));
    case ArtistsSort.nameDesc:
      sorted.sort((a, b) => _compare(b.name, a.name));
    case ArtistsSort.songCount:
      sorted.sort((a, b) {
        if (a.songCount != b.songCount) {
          return b.songCount.compareTo(a.songCount);
        }
        return _compare(a.name, b.name);
      });
    case ArtistsSort.albumCount:
      sorted.sort((a, b) {
        if (a.albumCount != b.albumCount) {
          return b.albumCount.compareTo(a.albumCount);
        }
        return _compare(a.name, b.name);
      });
    case ArtistsSort.mostPlayed:
      sorted.sort((a, b) {
        if (a.playCount != b.playCount) {
          return b.playCount.compareTo(a.playCount);
        }
        return _compare(a.name, b.name);
      });
  }
  return sorted;
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
