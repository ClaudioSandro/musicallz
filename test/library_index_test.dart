import 'package:flutter_test/flutter_test.dart';

import 'package:musicallz/features/library/domain/entities/song.dart';
import 'package:musicallz/features/library/domain/services/artist_names.dart';
import 'package:musicallz/features/library/domain/services/library_index.dart';

Song _song({
  required String id,
  required String title,
  required String artist,
  String album = 'Album',
  int? trackNumber,
  int playCount = 0,
  String? albumArtist,
  String? genre,
  DateTime? addedAt,
  DateTime? modifiedAt,
  Duration? duration,
}) =>
    Song(
      id: id,
      title: title,
      artist: artist,
      album: album,
      duration: duration ?? const Duration(seconds: 180),
      filePath: '/music/$id.mp3',
      trackNumber: trackNumber,
      playCount: playCount,
      albumArtist: albumArtist,
      genre: genre,
      addedAt: addedAt,
      modifiedAt: modifiedAt,
    );

void main() {
  group('ArtistNames.split', () {
    test('keeps a single artist intact', () {
      expect(ArtistNames.split('Aimer'), ['Aimer']);
      expect(ArtistNames.split('Red Hot Chili Peppers'),
          ['Red Hot Chili Peppers']);
    });

    test('splits on comma and semicolon', () {
      expect(ArtistNames.split('Aimer, LiSA'), ['Aimer', 'LiSA']);
      expect(ArtistNames.split('A; B'), ['A', 'B']);
    });

    test('splits on ampersand, ×, slash and pipe', () {
      expect(ArtistNames.split('A & B'), ['A', 'B']);
      expect(ArtistNames.split('A × B'), ['A', 'B']);
      expect(ArtistNames.split('A / B'), ['A', 'B']);
      expect(ArtistNames.split('A | B'), ['A', 'B']);
    });

    test('splits on feat tokens', () {
      expect(ArtistNames.split('Aimer feat. LiSA'), ['Aimer', 'LiSA']);
      expect(ArtistNames.split('Aimer feat LiSA'), ['Aimer', 'LiSA']);
      expect(ArtistNames.split('Aimer ft. LiSA'), ['Aimer', 'LiSA']);
      expect(ArtistNames.split('Aimer ft LiSA'), ['Aimer', 'LiSA']);
      expect(ArtistNames.split('Aimer featuring LiSA'), ['Aimer', 'LiSA']);
      expect(ArtistNames.split('Aimer with LiSA'), ['Aimer', 'LiSA']);
    });

    test('handles mixed separators and trims whitespace', () {
      expect(ArtistNames.split('A, B feat. C & D'),
          ['A', 'B', 'C', 'D']);
      expect(ArtistNames.split('  Aimer   feat.  LiSA  '),
          ['Aimer', 'LiSA']);
    });

    test('drops duplicates case-insensitively', () {
      expect(ArtistNames.split('A & a'), ['A']);
    });

    test('returns empty list for empty input', () {
      expect(ArtistNames.split(''), isEmpty);
      expect(ArtistNames.split('   '), isEmpty);
    });
  });

  group('LibraryIndex multi-artist', () {
    test('a collaborative song appears under every artist', () {
      final index = LibraryIndex.fromSongs([
        _song(id: 's1', title: 'One', artist: 'Aimer feat. LiSA'),
        _song(id: 's2', title: 'Two', artist: 'LiSA'),
        _song(id: 's3', title: 'Three', artist: 'Aimer'),
      ]);

      expect(index.artists.map((a) => a.name), containsAll(['Aimer', 'LiSA']));
      final aimer = index.artists.firstWhere((a) => a.name == 'Aimer');
      final lisa = index.artists.firstWhere((a) => a.name == 'LiSA');
      expect(aimer.songCount, 2);
      expect(lisa.songCount, 2);

      final aimerSongs = index.songsForArtist('aimer').map((s) => s.id);
      expect(aimerSongs, containsAll(['s1', 's3']));
      final lisaSongs = index.songsForArtist('lisa').map((s) => s.id);
      expect(lisaSongs, containsAll(['s1', 's2']));
    });

    test('search finds a song by any of its artists', () {
      final index = LibraryIndex.fromSongs([
        _song(id: 's1', title: 'One', artist: 'Aimer feat. LiSA'),
        _song(id: 's2', title: 'Two', artist: 'LiSA'),
      ]);

      final results = index.search('lisa');
      expect(results.songs.map((s) => s.id), containsAll(['s1', 's2']));
    });

    test('album is attributed to the album artist when present', () {
      final index = LibraryIndex.fromSongs([
        _song(
          id: 's1',
          title: 'One',
          artist: 'Aimer feat. LiSA',
          album: 'Collab',
          albumArtist: 'Various Artists',
        ),
        _song(
          id: 's2',
          title: 'Two',
          artist: 'Aimer',
          album: 'Collab',
          albumArtist: 'Various Artists',
        ),
      ]);

      final albums = index.albums.where((a) => a.title == 'Collab').toList();
      expect(albums, hasLength(1));
      expect(albums.single.artist, 'Various Artists');
      expect(albums.single.songCount, 2);
    });

    test('albumsForArtist includes albums where the artist collaborates', () {
      final index = LibraryIndex.fromSongs([
        _song(
          id: 's1',
          title: 'One',
          artist: 'Aimer feat. LiSA',
          album: 'Collab',
          albumArtist: 'Aimer',
        ),
        _song(id: 's2', title: 'Two', artist: 'LiSA', album: 'Solo'),
      ]);

      final lisaAlbums = index.albumsForArtist('lisa');
      expect(lisaAlbums.map((a) => a.title), containsAll(['Collab', 'Solo']));
      expect(lisaAlbums, hasLength(2));
    });

    test('artist playCount is the sum of its songs', () {
      final index = LibraryIndex.fromSongs([
        _song(id: 's1', title: 'One', artist: 'Aimer', playCount: 3),
        _song(id: 's2', title: 'Two', artist: 'Aimer', playCount: 2),
        _song(id: 's3', title: 'Three', artist: 'LiSA', playCount: 9),
      ]);

      expect(index.topArtists.first.name, 'LiSA');
      expect(index.topArtists.last.name, 'Aimer');
    });

    test('genres are distinct, trimmed and sorted', () {
      final index = LibraryIndex.fromSongs([
        _song(id: 's1', title: 'One', artist: 'A', genre: ' J-Pop '),
        _song(id: 's2', title: 'Two', artist: 'A', genre: 'Rock'),
        _song(id: 's3', title: 'Three', artist: 'B', genre: 'j-pop'),
        _song(id: 's4', title: 'Four', artist: 'B'),
      ]);

      expect(index.genres, ['J-Pop', 'Rock']);
      expect(index.songsForGenre('j-pop').map((s) => s.id), ['s1', 's3']);
      expect(index.albumsForGenre('Rock').map((a) => a.title), ['Album']);
    });

    test('recentlyAdded prefers the file modification date', () {
      final older = DateTime(2020);
      final newer = DateTime(2021);
      final oldest = DateTime(2019);
      final index = LibraryIndex.fromSongs([
        _song(
          id: 's1',
          title: 'Old',
          artist: 'A',
          addedAt: newer,
          modifiedAt: older,
        ),
        _song(
          id: 's2',
          title: 'New',
          artist: 'A',
          addedAt: older,
          modifiedAt: newer,
        ),
        _song(id: 's3', title: 'NoDate', artist: 'A', addedAt: oldest),
      ]);

      expect(index.recentlyAdded.map((s) => s.id), ['s2', 's1', 's3']);
    });

    test('sortedSongs supports most played and duration ordering', () {
      final index = LibraryIndex.fromSongs([
        _song(
          id: 's1',
          title: 'A',
          artist: 'A',
          playCount: 5,
          duration: const Duration(seconds: 100),
        ),
        _song(
          id: 's2',
          title: 'B',
          artist: 'A',
          playCount: 1,
          duration: const Duration(seconds: 300),
        ),
      ]);

      expect(index.sortedSongs(SongsSort.mostPlayed).first.id, 's1');
      expect(index.sortedSongs(SongsSort.durationLong).first.id, 's2');
      expect(index.sortedSongs(SongsSort.durationShort).first.id, 's1');
      expect(index.sortedSongs(SongsSort.titleDesc).first.id, 's2');
    });
  });
}
