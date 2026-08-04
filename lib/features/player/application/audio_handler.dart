import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart' hide PlayerState;

import '../../library/domain/entities/song.dart';

/// Bridges the single shared [AudioPlayer] to the Android media session.
///
/// This handler does NOT own a player: it controls the exact same [AudioPlayer]
/// instance used by [PlayerController]. Commands coming from the OS (notification,
/// lock screen, bluetooth, headset) are forwarded to that player, and playback
/// changes are published back to the OS. UI state stays in [PlayerController],
/// which subscribes to the same player streams.
class MusicallAudioHandler extends BaseAudioHandler {
  MusicallAudioHandler({required AudioPlayer player}) : _player = player {
    _subscriptions.addAll([
      player.currentIndexStream.listen(_onIndexChanged),
      player.playingStream.listen((_) => _broadcastState()),
      player.playerStateStream.listen((_) => _broadcastState()),
      player.positionStream.listen((_) => _broadcastState()),
      player.durationStream.listen((_) => _broadcastState()),
    ]);
    _configureSession();
  }

  final AudioPlayer _player;
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  int _queueIndex = -1;
  AudioServiceRepeatMode _repeat = AudioServiceRepeatMode.none;
  AudioServiceShuffleMode _shuffle = AudioServiceShuffleMode.none;

  /// Invoked when the OS changes the repeat mode. Wired to the controller so
  /// the app keeps a single source of truth.
  Future<void> Function(AudioServiceRepeatMode repeatMode)? onRepeatChanged;

  /// Invoked when the OS toggles shuffle. Wired to the controller.
  Future<void> Function(bool enabled)? onShuffleChanged;

  Future<void> _configureSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    } on Exception {
      // audio_service already manages the session when available.
    }
  }

  MediaItem _mediaItemFor(Song song) => MediaItem(
        id: song.id,
        title: song.title,
        artist: song.artist,
        album: song.album,
        duration: song.duration,
        artUri: song.albumArt != null
            ? Uri.dataFromBytes(song.albumArt!, mimeType: 'image/jpeg')
            : null,
      );

  void _onIndexChanged(int? index) {
    if (index == null || index < 0) return;
    final seq = _player.sequence;
    if (seq == null || index >= seq.length) return;
    final tag = seq[index].tag;
    if (tag is Song) {
      final item = _mediaItemFor(tag);
      if (mediaItem.valueOrNull?.id != item.id) {
        mediaItem.add(item);
      }
    }
    _queueIndex = index;
    _broadcastState();
  }

  /// Called by [PlayerController] whenever a new queue is loaded so the OS
  /// notification / media session reflects the current song list.
  void setQueue(List<Song> songs) {
    queue.add(songs.map(_mediaItemFor).toList());
    _broadcastState();
  }

  void reflectRepeat(AudioServiceRepeatMode repeatMode) {
    _repeat = repeatMode;
    _broadcastState();
  }

  void reflectShuffle(bool enabled) {
    _shuffle = enabled ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none;
    _broadcastState();
  }

  void _broadcastState() {
    final playing = _player.playing;
    playbackState.add(PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        playing ? MediaControl.pause : MediaControl.play,
        MediaControl.skipToNext,
      ],
      systemActions: const {MediaAction.seek},
      androidCompactActionIndices: const [0, 1, 2],
      processingState: switch (_player.processingState) {
        ProcessingState.idle => AudioProcessingState.idle,
        ProcessingState.loading => AudioProcessingState.loading,
        ProcessingState.buffering => AudioProcessingState.buffering,
        ProcessingState.ready => AudioProcessingState.ready,
        ProcessingState.completed => AudioProcessingState.completed,
      },
      playing: playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: 1.0,
      queueIndex: _queueIndex,
      repeatMode: _repeat,
      shuffleMode: _shuffle,
    ));
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    try {
      await _player.seekToNext();
    } on Exception {
      // Reached end of queue.
    }
  }

  @override
  Future<void> skipToPrevious() async {
    try {
      await _player.seekToPrevious();
    } on Exception {
      // Reached start of queue.
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    try {
      await _player.seek(Duration.zero, index: index);
      await _player.play();
    } on Exception {
      // Invalid index.
    }
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    _repeat = repeatMode;
    await onRepeatChanged?.call(repeatMode);
    _broadcastState();
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    _shuffle = shuffleMode;
    await onShuffleChanged?.call(shuffleMode == AudioServiceShuffleMode.all);
    _broadcastState();
  }
}