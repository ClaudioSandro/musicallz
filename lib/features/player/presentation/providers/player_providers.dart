import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../library/domain/entities/song.dart';
import '../../application/player_controller.dart';
import '../../domain/models/player_state.dart';
import 'audio_service_providers.dart';

final playerControllerProvider =
    StateNotifierProvider<PlayerController, PlayerState>(
  (ref) => PlayerController(
    ref.watch(audioPlayerProvider),
    audioHandler: ref.watch(audioHandlerProvider),
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