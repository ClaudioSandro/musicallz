import 'package:audio_service/audio_service.dart' as audio_service;
import 'package:audio_session/audio_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart' hide PlayerState;

import '../../library/domain/entities/song.dart';
import '../domain/models/player_state.dart';
import 'audio_handler.dart';

Uri songUri(Song song) {
  final path = song.filePath;
  if (path.startsWith('http://') || path.startsWith('https://')) {
    return Uri.parse(path);
  }
  return Uri.file(path);
}

/// Central playback controller.
///
/// It owns all playback logic and UI-facing state, but NOT a second player:
/// it controls the single shared [AudioPlayer] instance (also used by
/// [MusicallAudioHandler]). UI -> PlayerController -> AudioPlayer, and
/// OS commands -> AudioHandler -> same AudioPlayer -> PlayerController (via the
/// player streams) -> UI.
class PlayerController extends StateNotifier<PlayerState> {
  PlayerController(
    this._player, {
    MusicallAudioHandler? audioHandler,
  }) : super(PlayerState.initial) {
    _audioHandler = audioHandler;
    if (audioHandler != null) {
      audioHandler.onRepeatChanged = applyAudioRepeat;
      audioHandler.onShuffleChanged = applyAudioShuffle;
    }
    _configureSession();
    _subscribe();
  }

  final AudioPlayer _player;
  MusicallAudioHandler? _audioHandler;

  Future<void> _configureSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    } on Exception {
      // audio_service manages the session on Android when available.
    }
  }

  void _subscribe() {
    _player.playerStateStream.listen((ps) {
      final status = switch (ps.processingState) {
        ProcessingState.idle => PlayerStatus.idle,
        ProcessingState.loading => PlayerStatus.loading,
        ProcessingState.buffering => PlayerStatus.buffering,
        ProcessingState.completed => PlayerStatus.completed,
        ProcessingState.ready => ps.playing ? PlayerStatus.playing : PlayerStatus.paused,
      };
      state = state.copyWith(status: status);
    });

    _player.currentIndexStream.listen((idx) async {
      if (idx == null || idx < 0) return;
      final seq = _player.sequence;
      if (seq == null || idx >= seq.length) return;
      final tag = seq[idx].tag;
      if (tag is Song) {
        final pos = state.queue.indexOf(tag);
        if (pos >= 0 && pos != state.currentIndex) {
          state = state.copyWith(currentIndex: pos);
        }
      }
    });

    _player.positionStream.listen((pos) {
      state = state.copyWith(position: pos);
    });

    _player.durationStream.listen((dur) {
      state = state.copyWith(duration: dur);
    });
  }

  Future<void> playQueue(List<Song> queue, {int startIndex = 0}) async {
    if (queue.isEmpty) return;
    final safeIndex = startIndex.clamp(0, queue.length - 1);
    final playlist = ConcatenatingAudioSource(
      children: queue
          .map((s) => AudioSource.uri(songUri(s), tag: s))
          .toList(),
    );
    state = state.copyWith(
      queue: List<Song>.from(queue),
      currentIndex: safeIndex,
      status: PlayerStatus.loading,
    );
    try {
      await _player.setLoopMode(_loopFor(state.repeatMode));
      await _player.setShuffleModeEnabled(state.shuffleEnabled &&
          queue.length > 1);
      await _player.setAudioSource(playlist, initialIndex: safeIndex);
      await _player.play();
      _audioHandler?.setQueue(queue);
    } on Exception {
      // Playback errors are surfaced through the state streams.
    }
  }

  Future<void> playSong(Song song) =>
      playQueue([song], startIndex: 0);

  Future<void> togglePlayPause() async {
    if (!state.hasSong) return;
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> pause() async {
    await _player.pause();
    state = state.copyWith(status: PlayerStatus.paused);
  }

  Future<void> resume() async {
    await _player.play();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> skipToIndex(int index) async {
    if (!state.hasSong) return;
    final safe = index.clamp(0, state.queue.length - 1);
    await _player.seek(Duration.zero, index: safe);
  }

  Future<void> next() async {
    try {
      await _player.seekToNext();
    } on PlayerInterruptedException {
      // Ignored on manual navigation.
    } on Exception {
      // Ignored.
    }
  }

  Future<void> previous() async {
    try {
      await _player.seekToPrevious();
    } on Exception {
      // Ignored.
    }
  }

  Future<void> seekForward() => _seekBy(const Duration(seconds: 10));

  Future<void> seekBackward() => _seekBy(const Duration(seconds: -10));

  Future<void> _seekBy(Duration delta) async {
    final target = _player.position + delta;
    if (target < Duration.zero) {
      await _player.seek(Duration.zero);
    } else {
      await _player.seek(target);
    }
  }

  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
    state = state.copyWith(position: position);
  }

  Future<void> toggleShuffle() async {
    final enabled = !state.shuffleEnabled;
    state = state.copyWith(shuffleEnabled: enabled);
    if (enabled) {
      await _player.setShuffleModeEnabled(true);
      await _player.shuffle();
    } else {
      await _player.setShuffleModeEnabled(false);
    }
    _audioHandler?.reflectShuffle(enabled);
  }

  Future<void> cycleRepeat() async {
    final modes = RepeatMode.values;
    final nextIndex = (modes.indexOf(state.repeatMode) + 1) % modes.length;
    final next = modes[nextIndex];
    state = state.copyWith(repeatMode: next);
    await _player.setLoopMode(_loopFor(next));
    _audioHandler?.reflectRepeat(_audioRepeatFor(next));
  }

  /// Applies a repeat change requested from the OS, keeping [PlayerState] as the
  /// single source of truth and forwarding it to the shared player.
  Future<void> applyAudioRepeat(audio_service.AudioServiceRepeatMode mode) async {
    final ours = switch (mode) {
      audio_service.AudioServiceRepeatMode.none => RepeatMode.off,
      audio_service.AudioServiceRepeatMode.one => RepeatMode.one,
      audio_service.AudioServiceRepeatMode.all || audio_service.AudioServiceRepeatMode.group => RepeatMode.all,
    };
    state = state.copyWith(repeatMode: ours);
    await _player.setLoopMode(_loopFor(ours));
  }

  /// Applies a shuffle change requested from the OS.
  Future<void> applyAudioShuffle(bool enabled) async {
    state = state.copyWith(shuffleEnabled: enabled);
    if (enabled) {
      await _player.setShuffleModeEnabled(true);
      await _player.shuffle();
    } else {
      await _player.setShuffleModeEnabled(false);
    }
  }

  audio_service.AudioServiceRepeatMode _audioRepeatFor(RepeatMode mode) =>
      switch (mode) {
        RepeatMode.off => audio_service.AudioServiceRepeatMode.none,
        RepeatMode.one => audio_service.AudioServiceRepeatMode.one,
        RepeatMode.all => audio_service.AudioServiceRepeatMode.all,
      };

  LoopMode _loopFor(RepeatMode mode) => switch (mode) {
        RepeatMode.off => LoopMode.off,
        RepeatMode.all => LoopMode.all,
        RepeatMode.one => LoopMode.one,
      };

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}