import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:musicallz/features/library/domain/entities/song.dart';
import 'package:musicallz/features/player/presentation/providers/player_providers.dart';
import 'package:musicallz/features/player/presentation/screens/queue_screen.dart';

const _songA = Song(
  id: 'song-a',
  title: 'Song A',
  artist: 'Artist A',
  album: 'Album One',
  duration: Duration(minutes: 3, seconds: 3),
  filePath: '/music/song-a.mp3',
);
const _songB = Song(
  id: 'song-b',
  title: 'Song B',
  artist: 'Artist B',
  album: 'Album Two',
  duration: Duration(minutes: 4, seconds: 1),
  filePath: '/music/song-b.mp3',
);

Widget _app({
  Song? current = _songA,
  int currentIndex = 0,
  List<Song> upcoming = const [_songB],
}) {
  return ProviderScope(
    overrides: [
      currentSongProvider.overrideWithValue(current),
      currentIndexProvider.overrideWithValue(currentIndex),
      upcomingQueueProvider.overrideWithValue(upcoming),
      isPlayingProvider.overrideWithValue(true),
    ],
    child: const MaterialApp(home: QueueScreen()),
  );
}

void main() {
  testWidgets('Queue screen shows the current song and what is up next',
      (tester) async {
    await tester.pumpWidget(_app());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('NOW PLAYING'), findsOneWidget);
    expect(find.text('Song A'), findsOneWidget);
    expect(find.text('UP NEXT · 1'), findsOneWidget);
    expect(find.text('Song B'), findsOneWidget);
    expect(find.byType(ReorderableListView), findsOneWidget);
  });

  testWidgets('Queue screen handles an empty upcoming section',
      (tester) async {
    await tester.pumpWidget(_app(upcoming: const []));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('UP NEXT · EMPTY'), findsOneWidget);
    expect(
      find.textContaining('Nothing next in the queue'),
      findsOneWidget,
    );
  });

  testWidgets('Queue screen shows an empty state when nothing plays',
      (tester) async {
    await tester.pumpWidget(_app(current: null, upcoming: const []));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Nothing playing'), findsOneWidget);
  });
}
