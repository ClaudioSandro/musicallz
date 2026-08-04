import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:musicallz/app/app.dart';
import 'package:musicallz/features/library/domain/entities/song.dart';
import 'package:musicallz/features/library/domain/repositories/music_repository.dart';
import 'package:musicallz/features/library/presentation/providers/library_permission_provider.dart';
import 'package:musicallz/features/library/presentation/providers/music_repository_provider.dart';

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

Widget _app() => ProviderScope(
      overrides: [
        musicRepositoryProvider.overrideWithValue(_FakeMusicRepository()),
        libraryPermissionProvider
            .overrideWith((ref) async => PermissionStatus.granted),
      ],
      child: const MusicallzApp(),
    );

void main() {
  testWidgets('Musicallz boots with bottom navigation', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Your Library'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Musicallz'), findsOneWidget);
  });

  testWidgets('Home lists songs in Recently Added', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    expect(find.text('Recently Added'), findsOneWidget);
    expect(find.text('Song A'), findsOneWidget);
    expect(find.text('3:03'), findsOneWidget);
  });

  testWidgets('Navigates between bottom navigation destinations', (tester) async {
    await tester.pumpWidget(_app());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Configuraciones futuras'), findsOneWidget);

    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    expect(find.text('Explorar géneros'), findsOneWidget);

    await tester.tap(find.text('Your Library'));
    await tester.pumpAndSettle();
    expect(find.text('2 canciones'), findsOneWidget);
    expect(find.text('Rescan Library'), findsOneWidget);
  });
}