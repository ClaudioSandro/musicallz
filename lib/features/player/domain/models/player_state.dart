import '../../../library/domain/entities/song.dart';

enum PlayerStatus { idle, loading, buffering, playing, paused, completed }

enum RepeatMode { off, all, one }

class PlayerState {
  const PlayerState({
    this.queue = const [],
    this.currentIndex = -1,
    this.status = PlayerStatus.idle,
    this.shuffleEnabled = false,
    this.repeatMode = RepeatMode.off,
    this.position = Duration.zero,
    this.duration,
  });

  static const PlayerState initial = PlayerState();

  final List<Song> queue;
  final int currentIndex;
  final PlayerStatus status;
  final bool shuffleEnabled;
  final RepeatMode repeatMode;
  final Duration position;
  final Duration? duration;

  Song? get currentSong => currentIndex >= 0 && currentIndex < queue.length
      ? queue[currentIndex]
      : null;

  bool get hasSong => currentSong != null;

  bool get isPlaying => status == PlayerStatus.playing;

  Duration get effectiveDuration =>
      duration ?? currentSong?.duration ?? Duration.zero;

  PlayerState copyWith({
    List<Song>? queue,
    int? currentIndex,
    PlayerStatus? status,
    bool? shuffleEnabled,
    RepeatMode? repeatMode,
    Duration? position,
    Duration? duration,
    bool clearCurrent = false,
  }) {
    return PlayerState(
      queue: queue ?? this.queue,
      currentIndex: clearCurrent ? -1 : (currentIndex ?? this.currentIndex),
      status: status ?? this.status,
      shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
      repeatMode: repeatMode ?? this.repeatMode,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }
}