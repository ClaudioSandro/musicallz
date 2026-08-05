import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:musicallz/app/app.dart';
import 'package:musicallz/app/router.dart';
import 'package:musicallz/features/library/domain/entities/song.dart';
import 'package:musicallz/features/library/domain/repositories/music_repository.dart';
import 'package:musicallz/features/library/presentation/providers/library_permission_provider.dart';
import 'package:musicallz/features/library/presentation/providers/music_repository_provider.dart';
import 'package:musicallz/features/playlists/presentation/providers/playlist_providers.dart';
import 'package:musicallz/shared/widgets/song_list_tile.dart';

import 'helpers.dart';

class _FakeMusicRepository implements MusicRepository {
  @override
  Future<List<Song>> getSongs() async => const [
    Song(
      id: 'song-1',
      title: 'Song A',
      artist: 'Artist A',
      album: 'Album One',
      duration: Duration(seconds: 183),
      filePath: '/music/song-a.mp3',
    ),
    Song(
      id: 'song-2',
      title: 'Song B',
      artist: 'Artist B',
      album: 'Album Two',
      duration: Duration(seconds: 241),
      filePath: '/music/song-b.mp3',
    ),
  ];
}

late InMemoryPlaylistRepository playlistsRepo;
late InMemoryFavoritesRepository favoritesRepo;

Widget _app() => ProviderScope(
      overrides: [
        musicRepositoryProvider.overrideWithValue(_FakeMusicRepository()),
        libraryPermissionProvider
            .overrideWith((ref) async => PermissionStatus.granted),
        playlistRepositoryProvider.overrideWithValue(playlistsRepo),
        favoritesRepositoryProvider.overrideWithValue(favoritesRepo),
      ],
      child: const MusicallzApp(),
    );

Future<void> _boot(WidgetTester tester) async {
  await tester.pumpWidget(_app());
  await tester.pumpAndSettle();
  appRouter.go('/home');
  await tester.pumpAndSettle();
}

Future<void> _openLibrary(WidgetTester tester) async {
  await tester.tap(
    find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text('Your Library'),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    playlistsRepo = InMemoryPlaylistRepository();
    favoritesRepo = InMemoryFavoritesRepository();
  });

  testWidgets('Library shows Liked Songs and Create Playlist', (tester) async {
    await _boot(tester);
    await _openLibrary(tester);

    expect(find.text('Liked Songs'), findsOneWidget);
    expect(find.text('Create Playlist'), findsOneWidget);
  });

  testWidgets('Creating a playlist adds it to the library', (tester) async {
    await _boot(tester);
    await _openLibrary(tester);

    await tester.tap(find.text('Create Playlist'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Road Trip');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(find.text('Road Trip'), findsOneWidget);
    expect(find.textContaining('0 songs'), findsOneWidget);
  });

  testWidgets('Dialog rejects an empty playlist name', (tester) async {
    await _boot(tester);
    await _openLibrary(tester);

    await tester.tap(find.text('Create Playlist'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(find.text('Give your playlist a name'), findsOneWidget);
    expect(find.text('Road Trip'), findsNothing);
  });

  testWidgets('Favoriting a song shows it in Liked Songs', (tester) async {
    await _boot(tester);

    final songARow = find.ancestor(
      of: find.text('Song A'),
      matching: find.byType(SongListTile),
    );
    await tester.tap(
      find.descendant(
        of: songARow,
        matching: find.byIcon(Icons.favorite_border),
      ),
    );
    await tester.pumpAndSettle();

    await _openLibrary(tester);
    await tester.tap(find.text('Liked Songs'));
    await tester.pumpAndSettle();

    expect(find.text('Song A'), findsOneWidget);
    expect(find.textContaining('1 song'), findsOneWidget);
  });

  testWidgets('Adding a song to a playlist via the context menu persists',
      (tester) async {
    await playlistsRepo.createPlaylist('Gym Mix');

    await _boot(tester);

    final songARow = find.ancestor(
      of: find.text('Song A'),
      matching: find.byType(SongListTile),
    );
    await tester.tap(
      find.descendant(
        of: songARow,
        matching: find.byIcon(Icons.more_horiz),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add to playlist'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Gym Mix'));
    await tester.pumpAndSettle();

    expect(find.text('Added to Gym Mix'), findsOneWidget);

    await _openLibrary(tester);
    await tester.tap(find.text('Gym Mix'));
    await tester.pumpAndSettle();

    expect(find.text('Song A'), findsOneWidget);
    expect(find.textContaining('1 song'), findsOneWidget);
  });

  testWidgets('Context menu does not overflow on short screens', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 480));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await _boot(tester);

    final songARow = find.ancestor(
      of: find.text('Song A'),
      matching: find.byType(SongListTile),
    );
    await tester.tap(
      find.descendant(
        of: songARow,
        matching: find.byIcon(Icons.more_horiz),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Play next'), findsOneWidget);
  });

  testWidgets('Playlist detail plays and reorders its songs', (tester) async {
    final playlist = await playlistsRepo.createPlaylist(
      'Favorites Mix',
      description: 'Best of the library',
    );
    await playlistsRepo.addSong(playlist.id, 'song-1');
    await playlistsRepo.addSong(playlist.id, 'song-2');

    await _boot(tester);
    await _openLibrary(tester);

    await tester.tap(find.text('Favorites Mix'));
    await tester.pumpAndSettle();

    expect(find.text('Best of the library'), findsOneWidget);
    expect(find.textContaining('2 songs'), findsOneWidget);
    expect(find.text('Song A'), findsOneWidget);
    expect(find.text('Song B'), findsOneWidget);
    expect(find.byType(ReorderableListView), findsOneWidget);
  });
}