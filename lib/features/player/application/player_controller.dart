import 'dart:async';

import 'package:audio_service/audio_service.dart' as audio_service;
import 'package:audio_session/audio_session.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart' hide PlayerState;

import '../../library/domain/entities/song.dart';
import '../domain/models/player_state.dart';
import 'audio_handler.dart';
import 'session_store.dart';

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
///
/// When a [SessionStore] is provided the last queue is restored on startup
/// (paused, never auto-played) and the session is persisted while playing.
class PlayerController extends StateNotifier<PlayerState> {
  PlayerController(
    this._player, {
    MusicallAudioHandler? audioHandler,
    SessionStore? sessionStore,
    Future<void> Function(Song song)? onSongStarted,
  }) : super(PlayerState.initial) {
    _audioHandler = audioHandler;
    _sessionStore = sessionStore;
    _onSongStarted = onSongStarted;
    if (audioHandler != null) {
      audioHandler.onRepeatChanged = applyAudioRepeat;
      audioHandler.onShuffleChanged = applyAudioShuffle;
    }
    _configureSession();
    _subscribe();
    unawaited(_restoreSession());
    _sessionTimer =
        Timer.periodic(const Duration(seconds: 15), (_) => _persistSession());
  }

  final AudioPlayer _player;
  MusicallAudioHandler? _audioHandler;
  SessionStore? _sessionStore;
  Future<void> Function(Song song)? _onSongStarted;
  Timer? _sessionTimer;
  String? _lastRecordedSongId;

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
        ProcessingState.ready =>
          ps.playing ? PlayerStatus.playing : PlayerStatus.paused,
      };
      state = state.copyWith(status: status);

      // Count a play only once per track, and only when it is actually
      // playing (restored sessions stay paused, so they do not inflate counts).
      if (ps.processingState == ProcessingState.ready && ps.playing) {
        final idx = _player.currentIndex;
        final seq = _player.sequence;
        if (idx != null && seq != null && idx < seq.length) {
          final tag = seq[idx].tag;
          if (tag is Song) _recordPlayIfChanged(tag);
        }
      }
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

  void _recordPlayIfChanged(Song song) {
    if (_lastRecordedSongId == song.id) return;
    _lastRecordedSongId = song.id;
    unawaited(_onSongStarted?.call(song) ?? Future.value());
  }

  // ---------------------------------------------------------------------------
  // Session persistence
  // ---------------------------------------------------------------------------

  Future<void> _restoreSession() async {
    try {
      final data = await _sessionStore?.load();
      if (data == null || data.queue.isEmpty) return;
      final queue = data.queue;
      final safeIndex = data.currentIndex.clamp(0, queue.length - 1);
      final playlist = ConcatenatingAudioSource(
        children: queue
            .map((s) => AudioSource.uri(songUri(s), tag: s))
            .toList(),
      );
      await _player.setLoopMode(_loopFor(data.repeatMode));
      await _player.setShuffleModeEnabled(
        data.shuffleEnabled && queue.length > 1,
      );
      // Restored sessions never auto-play.
      await _player.setAudioSource(
        playlist,
        initialIndex: safeIndex,
        initialPosition: data.position,
      );
      state = state.copyWith(
        queue: List<Song>.from(queue),
        currentIndex: safeIndex,
        position: data.position,
        shuffleEnabled: data.shuffleEnabled,
        repeatMode: data.repeatMode,
        status: PlayerStatus.paused,
      );
      _audioHandler?.setQueue(queue);
      _audioHandler?.reflectRepeat(_audioRepeatFor(data.repeatMode));
      _audioHandler?.reflectShuffle(data.shuffleEnabled);
    } on Exception {
      // Never block startup on a corrupt snapshot.
    }
  }

  Future<void> _persistSession() async {
    final store = _sessionStore;
    if (store == null) return;
    try {
      await store.save(
        SessionSnapshotData(
          queue: List<Song>.from(state.queue),
          currentIndex: state.currentIndex,
          position: state.hasSong ? _player.position : Duration.zero,
          shuffleEnabled: state.shuffleEnabled,
          repeatMode: state.repeatMode,
        ),
      );
    } on Exception {
      // Persistence must never break playback.
    }
  }

  // ---------------------------------------------------------------------------
  // Queue control
  // ---------------------------------------------------------------------------

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
      await _player.setShuffleModeEnabled(
        state.shuffleEnabled && queue.length > 1,
      );
      await _player.setAudioSource(playlist, initialIndex: safeIndex);
      await _player.play();
      _audioHandler?.setQueue(queue);
    } on Exception {
      // Playback errors are surfaced through the state streams.
    }
    _persistSession();
  }

  Future<void> playSong(Song song) => playQueue([song], startIndex: 0);

  /// Inserts [song] right after the current track. Falls back to playing it
  /// when the player is empty.
  Future<void> playNext(Song song) async {
    if (!state.hasSong) {
      await playSong(song);
      return;
    }
    if (state.currentSong?.id == song.id) return;
    final queue = List<Song>.from(state.queue);
    final existing = queue.indexWhere((s) => s.id == song.id);
    if (existing != -1) queue.removeAt(existing);
    var insertAt = state.currentIndex + 1;
    if (existing != -1 && existing < state.currentIndex) insertAt -= 1;
    insertAt = insertAt.clamp(0, queue.length);
    queue.insert(insertAt, song);
    var cur = state.currentIndex;
    if (existing != -1 && existing < state.currentIndex) cur -= 1;
    await _applyQueue(
      queue,
      startIndex: cur.clamp(0, queue.length - 1),
      resumeIfPlaying: true,
    );
  }

  /// Appends [song] to the end of the queue. Falls back to playing it when
  /// the player is empty.
  Future<void> addToQueue(Song song) async {
    if (!state.hasSong) {
      await playSong(song);
      return;
    }
    if (state.queue.any((s) => s.id == song.id)) return;
    final queue = [...state.queue, song];
    await _applyQueue(queue, startIndex: state.currentIndex, resumeIfPlaying: true);
  }

  Future<void> removeFromQueue(int index) async {
    if (!state.hasSong) return;
    final queue = List<Song>.from(state.queue);
    if (index < 0 || index >= queue.length) return;
    final wasCurrent = index == state.currentIndex;
    final wasPlaying = state.isPlaying;
    queue.removeAt(index);
    if (queue.isEmpty) {
      await stop();
      await _persistSession();
      return;
    }
    var newIndex = state.currentIndex;
    if (index < state.currentIndex) newIndex -= 1;
    newIndex = newIndex.clamp(0, queue.length - 1);
    await _applyQueue(
      queue,
      startIndex: newIndex,
      resumeIfPlaying: wasPlaying,
      initialPosition: wasCurrent ? Duration.zero : null,
    );
  }

  Future<void> reorderQueue(int from, int to) async {
    if (!state.hasSong) return;
    final queue = List<Song>.from(state.queue);
    if (from < 0 ||
        from >= queue.length ||
        to < 0 ||
        to >= queue.length ||
        from == to) {
      return;
    }
    final wasPlaying = state.isPlaying;
    final moved = queue.removeAt(from);
    queue.insert(to, moved);
    var cur = state.currentIndex;
    if (from == cur) {
      cur = to;
    } else if (from < cur && to >= cur) {
      cur -= 1;
    } else if (from > cur && to <= cur) {
      cur += 1;
    }
    await _applyQueue(
      queue,
      startIndex: cur.clamp(0, queue.length - 1),
      resumeIfPlaying: wasPlaying,
    );
  }

  /// Rebuilds the shared player's source around [queue] without changing what
  /// is audible: the same current song keeps playing (optionally resuming) at
  /// the given position.
  Future<void> _applyQueue(
    List<Song> queue, {
    int? startIndex,
    bool resumeIfPlaying = false,
    Duration? initialPosition,
  }) async {
    if (queue.isEmpty) return;
    final wasPlaying = resumeIfPlaying && state.isPlaying;
    final safeIndex = (startIndex ?? state.currentIndex).clamp(0, queue.length - 1);
    final position = initialPosition ?? _player.position;
    final playlist = ConcatenatingAudioSource(
      children: queue
          .map((s) => AudioSource.uri(songUri(s), tag: s))
          .toList(),
    );
    state = state.copyWith(
      queue: List<Song>.from(queue),
      currentIndex: safeIndex,
    );
    try {
      await _player.setLoopMode(_loopFor(state.repeatMode));
      await _player.setShuffleModeEnabled(
        state.shuffleEnabled && queue.length > 1,
      );
      await _player.setAudioSource(
        playlist,
        initialIndex: safeIndex,
        initialPosition: position,
      );
      if (resumeIfPlaying && wasPlaying) await _player.play();
    } on Exception {
      // Playback errors are surfaced through the state streams.
    }
    _audioHandler?.setQueue(queue);
    _persistSession();
  }

  // ---------------------------------------------------------------------------
  // Transport
  // ---------------------------------------------------------------------------

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
    _persistSession();
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
    _persistSession();
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
    _persistSession();
  }

  Future<void> cycleRepeat() async {
    final modes = RepeatMode.values;
    final nextIndex = (modes.indexOf(state.repeatMode) + 1) % modes.length;
    final next = modes[nextIndex];
    state = state.copyWith(repeatMode: next);
    await _player.setLoopMode(_loopFor(next));
    _audioHandler?.reflectRepeat(_audioRepeatFor(next));
    _persistSession();
  }

  /// Applies a repeat change requested from the OS, keeping [PlayerState] as the
  /// single source of truth and forwarding it to the shared player.
  Future<void> applyAudioRepeat(audio_service.AudioServiceRepeatMode mode) async {
    final ours = switch (mode) {
      audio_service.AudioServiceRepeatMode.none => RepeatMode.off,
      audio_service.AudioServiceRepeatMode.one => RepeatMode.one,
      audio_service.AudioServiceRepeatMode.all ||
      audio_service.AudioServiceRepeatMode.group =>
        RepeatMode.all,
    };
    state = state.copyWith(repeatMode: ours);
    await _player.setLoopMode(_loopFor(ours));
    _persistSession();
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
    _persistSession();
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
    _sessionTimer?.cancel();
    unawaited(_persistSession());
    _player.dispose();
    super.dispose();
  }
}
