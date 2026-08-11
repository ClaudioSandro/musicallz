import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:musicallz/app/app.dart';
import 'package:musicallz/app/router.dart';
import 'package:musicallz/features/library/data/models/library_scan_metrics.dart';
import 'package:musicallz/features/library/domain/entities/song.dart';
import 'package:musicallz/features/library/domain/repositories/music_repository.dart';
import 'package:musicallz/features/library/presentation/providers/library_permission_provider.dart';
import 'package:musicallz/features/library/presentation/providers/music_repository_provider.dart';
import 'package:musicallz/features/library/presentation/widgets/album_card.dart';
import 'package:musicallz/features/library/presentation/widgets/artist_tile.dart';
import 'package:musicallz/features/player/domain/models/player_state.dart';
import 'package:musicallz/features/player/presentation/providers/player_providers.dart';
import 'package:musicallz/features/player/presentation/screens/now_playing_screen.dart';
import 'package:musicallz/features/playlists/presentation/providers/playlist_providers.dart';
import 'package:musicallz/shared/widgets/marquee_text.dart';

import 'helpers.dart';

const _long = 'This is an extremely long song or album title used to check '
    'that no render overflow happens on narrow screens, it keeps going and '
    'going and going without ever stopping or giving up, never stops never '
    'stops never stops.';

class _LongTitleRepository implements MusicRepository {
  @override
  Future<List<Song>> getSongs() async => List.generate(
        4,
        (i) => Song(
          id: 'song-$i',
          title: '$_long $i',
          artist: '$_long artist $i',
          album: '$_long album $i',
          duration: Duration(minutes: 3, seconds: 3),
          filePath: '/music/$i.mp3',
          year: 2020 + i,
          trackNumber: i + 1,
        ),
      );

  @override
  Future<List<Song>> rescan() async => getSongs();

  @override
  Future<LibraryScanMetrics?> scanMetrics() async => null;

  @override
  Future<void> recordPlay(String songId) async {}
}

Widget _app() => ProviderScope(
      overrides: [
        musicRepositoryProvider.overrideWithValue(_LongTitleRepository()),
        libraryPermissionProvider
            .overrideWith((ref) async => PermissionStatus.granted),
        playlistRepositoryProvider
            .overrideWithValue(InMemoryPlaylistRepository()),
        favoritesRepositoryProvider
            .overrideWithValue(InMemoryFavoritesRepository()),
      ],
      child: const MusicallzApp(),
    );

Future<void> _openLibrary(WidgetTester tester) async {
  await tester.tap(
    find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text('Tu biblioteca'),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _openTab(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(
      of: find.byType(TabBar),
      matching: find.text(label),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _boot(WidgetTester tester) async {
  await tester.pumpWidget(_app());
  await tester.pumpAndSettle();
  // The app router is global and keeps its location across tests; reset it so
  // every test boots from Home with the bottom navigation available.
  appRouter.go('/home');
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('No overflow with long titles on Home', (tester) async {
    await _boot(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('No overflow with long titles on Library albums tab',
      (tester) async {
    await _boot(tester);
    await _openLibrary(tester);
    await _openTab(tester, 'Álbumes');
    expect(tester.takeException(), isNull);
  });

  testWidgets('No overflow in album detail with long titles', (tester) async {
    await _boot(tester);
    await _openLibrary(tester);
    await _openTab(tester, 'Álbumes');

    await tester.tap(find.byType(AlbumCard).first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('No overflow in artist detail with long titles', (tester) async {
    await _boot(tester);
    await _openLibrary(tester);
    await _openTab(tester, 'Artistas');

    await tester.tap(find.byType(ArtistTile).first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Marquee renders text and does not overflow', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 160,
              child: MarqueeText(
                _long,
                style: TextStyle(fontSize: 22, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 900));
    expect(tester.takeException(), isNull);
    expect(find.textContaining('extremely long'), findsWidgets);
  });

  testWidgets('No overflow with long titles and enlarged text scale',
      (tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(textScaler: const TextScaler.linear(1.4)),
        child: _app(),
      ),
    );
    await tester.pumpAndSettle();
    appRouter.go('/home');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await _openLibrary(tester);
    await _openTab(tester, 'Álbumes');
    expect(tester.takeException(), isNull);

    await tester.tap(find.byType(AlbumCard).first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('Now Playing does not overflow on short screens', (tester) async {
    tester.view.physicalSize = const Size(360, 520);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final song = (await _LongTitleRepository().getSongs()).first;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          favoritesRepositoryProvider
              .overrideWithValue(InMemoryFavoritesRepository()),
          currentSongProvider.overrideWithValue(song),
          isPlayingProvider.overrideWithValue(true),
          currentPositionProvider.overrideWithValue(Duration.zero),
          totalDurationProvider
              .overrideWithValue(const Duration(minutes: 3, seconds: 30)),
          shuffleStateProvider.overrideWithValue(false),
          repeatStateProvider.overrideWithValue(RepeatMode.off),
        ],
        child: const MaterialApp(home: NowPlayingScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.takeException(), isNull);
  });
}
