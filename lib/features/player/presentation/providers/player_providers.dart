import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../library/domain/entities/song.dart';
import '../../../library/presentation/providers/music_repository_provider.dart';
import '../../application/player_controller.dart';
import '../../application/session_store.dart';
import '../../domain/models/player_state.dart';
import 'audio_service_providers.dart';

/// Stores/restores the playback session. Overridden in `main()` with an
/// Isar-backed store; tests use the in-memory no-op.
final sessionStoreProvider = Provider<SessionStore>(
  (ref) => NoopSessionStore(),
);

final playerControllerProvider =
    StateNotifierProvider<PlayerController, PlayerState>(
  (ref) => PlayerController(
    ref.watch(audioPlayerProvider),
    audioHandler: ref.watch(audioHandlerProvider),
    sessionStore: ref.watch(sessionStoreProvider),
    onSongStarted: (song) => ref.read(musicRepositoryProvider).recordPlay(song.id),
  ),
);

final currentSongProvider = Provider<Song?>(
  (ref) => ref.watch(playerControllerProvider.select((s) => s.currentSong)),
);

final currentIndexProvider = Provider<int>(
  (ref) => ref.watch(playerControllerProvider.select((s) => s.currentIndex)),
);

final playbackStateProvider = Provider<PlayerStatus>(
  (ref) => ref.watch(playerControllerProvider.select((s) => s.status)),
);

final isPlayingProvider = Provider<bool>(
  (ref) => ref.watch(playerControllerProvider.select((s) => s.isPlaying)),
);

final queueProvider = Provider<List<Song>>(
  (ref) => ref.watch(playerControllerProvider.select((s) => s.queue)),
);

/// Everything queued after the current song (what the Queue screen shows).
final upcomingQueueProvider = Provider<List<Song>>(
  (ref) {
    final state = ref.watch(playerControllerProvider);
    if (!state.hasSong) return const [];
    final start = state.currentIndex + 1;
    if (start >= state.queue.length) return const [];
    return state.queue.sublist(start);
  },
);

final currentPositionProvider = Provider<Duration>(
  (ref) => ref.watch(playerControllerProvider.select((s) => s.position)),
);

final totalDurationProvider = Provider<Duration>(
  (ref) => ref.watch(playerControllerProvider.select((s) => s.effectiveDuration)),
);

final shuffleStateProvider = Provider<bool>(
  (ref) => ref.watch(playerControllerProvider.select((s) => s.shuffleEnabled)),
);

final repeatStateProvider = Provider<RepeatMode>(
  (ref) => ref.watch(playerControllerProvider.select((s) => s.repeatMode)),
);

final hasActiveSongProvider = Provider<bool>(
  (ref) => ref.watch(playerControllerProvider.select((s) => s.hasSong)),
);
