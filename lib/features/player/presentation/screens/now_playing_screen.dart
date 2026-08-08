import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/theme_extension.dart';
import '../../../../core/theme/theme_backdrop.dart';
import '../../../../core/utils/color_utils.dart';
import '../../../../core/utils/format_duration.dart';
import '../../../library/domain/entities/song.dart';
import '../../../library/presentation/widgets/cover_art.dart';
import '../../domain/models/player_state.dart';
import '../../../../shared/widgets/marquee_text.dart';
import '../../../../shared/widgets/seek_bar.dart';
import '../../../../shared/widgets/favorite_button.dart';
import '../providers/player_providers.dart';

class NowPlayingScreen extends ConsumerStatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  ConsumerState<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends ConsumerState<NowPlayingScreen> {
  double? _dragMs;
  Color? _baseColor;
  Timer? _colorDebounce;

  @override
  void initState() {
    super.initState();
    final song = ref.read(currentSongProvider);
    if (song != null) _scheduleColorExtract(song);
  }

  @override
  void dispose() {
    _colorDebounce?.cancel();
    super.dispose();
  }

  void _scheduleColorExtract(Song song) {
    _colorDebounce?.cancel();
    final bytes = song.albumArt;
    final path = song.albumArtPath;
    if (bytes == null && path == null) {
      setState(() => _baseColor = null);
      return;
    }
    _colorDebounce = Timer(const Duration(milliseconds: 250), () async {
      Uint8List? data = bytes;
      if (data == null && path != null) {
        try {
          data = await File(path).readAsBytes();
        } on Exception {
          data = null;
        }
      }
      if (data == null) {
        if (mounted) setState(() => _baseColor = null);
        return;
      }
      final color = await extractDominantColor(data);
      if (mounted && ref.read(currentSongProvider)?.id == song.id) {
        setState(() => _baseColor = color);
      }
    });
  }

  ImageProvider? _artworkProvider(Song? song) {
    if (song == null) return null;
    final bytes = song.albumArt;
    if (bytes != null) return MemoryImage(bytes);
    final path = song.albumArtPath;
    if (path != null && File(path).existsSync()) return FileImage(File(path));
    return null;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<Song?>(currentSongProvider, (previous, next) {
      if (next != null && next.id != previous?.id) {
        _scheduleColorExtract(next);
      }
    });

    final song = ref.watch(currentSongProvider);
    final playing = ref.watch(isPlayingProvider);
    final position = ref.watch(currentPositionProvider);
    final duration = ref.watch(totalDurationProvider);
    final shuffle = ref.watch(shuffleStateProvider);
    final repeat = ref.watch(repeatStateProvider);

    final maxMs = duration.inMilliseconds.toDouble().clamp(1, double.infinity);
    final displayMs =
        (_dragMs ?? position.inMilliseconds.toDouble()).clamp(0.0, maxMs);
    final displayPos = Duration(milliseconds: displayMs.round());
    final remaining = duration - displayPos;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null &&
              details.primaryVelocity! > 500) {
            context.pop();
          }
        },
        child: ThemeBackdrop(
          artColor: _baseColor,
          image: _artworkProvider(song),
          child: SafeArea(
            child: Column(
              children: [
                _TopBar(),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragEnd: (details) {
                      final ctrl =
                          ref.read(playerControllerProvider.notifier);
                      if (details.primaryVelocity != null) {
                        if (details.primaryVelocity! < -300) {
                          HapticFeedback.lightImpact();
                          ctrl.next();
                        } else if (details.primaryVelocity! > 300) {
                          HapticFeedback.lightImpact();
                          ctrl.previous();
                        }
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // The middle area is a fixed-size stack (cover + gap +
                          // title block) that would overflow on short screens.
                          // Compute the cover size from the available height so
                          // everything always fits without a scrollable.
                          const gap = 40.0;
                          const titleHeight = 96.0;
                          final coverSize =
                              (constraints.maxHeight - gap - titleHeight)
                                  .clamp(80.0, 300.0);
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder: (child, animation) =>
                                    FadeTransition(
                                  opacity: animation,
                                  child: ScaleTransition(
                                    scale: Tween(begin: 0.94, end: 1.0)
                                        .animate(animation),
                                    child: child,
                                  ),
                                ),
                                child: Hero(
                                  key: ValueKey('hero-${song?.id ?? 'none'}'),
                                  tag: 'song-art-${song?.id ?? 'none'}',
                                  child: CoverArt(
                                    bytes: song?.albumArt,
                                    filePath: song?.albumArtPath,
                                    size: coverSize,
                                    radius: 24,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                              _TitleBlock(
                                key: ValueKey('title-${song?.id ?? 'none'}'),
                                title: song?.title ?? '',
                                artist: song?.artist ?? '',
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      SeekBar(
                        position: displayPos,
                        duration: duration,
                        onChangeEnd: (value) {
                          HapticFeedback.selectionClick();
                          ref
                              .read(playerControllerProvider.notifier)
                              .seekTo(value);
                          setState(() => _dragMs = null);
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formatDuration(displayPos),
                            style: TextStyle(
                              fontSize: 11,
                              color: context.appTheme.headerTextMuted,
                            ),
                          ),
                          Text(
                            formatDuration(remaining),
                            style: TextStyle(
                              fontSize: 11,
                              color: context.appTheme.headerTextMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _ControlButton(
                                icon: Icons.shuffle,
                                size: 20,
                                color: shuffle
                                    ? context.appTheme.gradientStart
                                    : context.appTheme.headerTextMuted,
                                onTap: () => ref
                                    .read(playerControllerProvider.notifier)
                                    .toggleShuffle(),
                                tooltip: 'Shuffle',
                                boxSize: 38,
                              ),
                              const SizedBox(width: 6),
                              _ControlButton(
                                icon: Icons.skip_previous_rounded,
                                size: 30,
                                onTap: () => ref
                                    .read(playerControllerProvider.notifier)
                                    .previous(),
                                tooltip: 'Previous',
                                boxSize: 44,
                              ),
                              const SizedBox(width: 6),
                              _ControlButton(
                                icon: Icons.replay_10,
                                size: 22,
                                color: Colors.white.withValues(alpha: 0.9),
                                onTap: () => ref
                                    .read(playerControllerProvider.notifier)
                                    .seekBackward(),
                                tooltip: 'Back 10 seconds',
                                boxSize: 38,
                              ),
                              const SizedBox(width: 6),
                              _PlayPauseButton(playing: playing),
                              const SizedBox(width: 6),
                              _ControlButton(
                                icon: Icons.forward_10,
                                size: 22,
                                color: Colors.white.withValues(alpha: 0.9),
                                onTap: () => ref
                                    .read(playerControllerProvider.notifier)
                                    .seekForward(),
                                tooltip: 'Forward 10 seconds',
                                boxSize: 38,
                              ),
                              const SizedBox(width: 6),
                              _ControlButton(
                                icon: Icons.skip_next_rounded,
                                size: 30,
                                onTap: () => ref
                                    .read(playerControllerProvider.notifier)
                                    .next(),
                                tooltip: 'Next',
                                boxSize: 44,
                              ),
                              const SizedBox(width: 6),
                              _RepeatButton(mode: repeat),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends ConsumerWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final song = ref.watch(currentSongProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.keyboard_arrow_down,
                color: Colors.white, size: 32),
            tooltip: 'Collapse',
          ),
          const Expanded(
            child: Text(
              'NOW PLAYING',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ),
          if (song != null) ...[
            IconButton(
              onPressed: () => context.push('/queue'),
              icon: const Icon(Icons.queue_music, color: Colors.white70, size: 22),
              tooltip: 'Queue',
            ),
            const SizedBox(width: 4),
            FavoriteButton(songId: song.id, size: 24),
          ] else
            const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({super.key, required this.title, required this.artist});

  final String title;
  final String artist;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MarqueeText(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              color: context.appTheme.headerTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.size,
    required this.onTap,
    required this.tooltip,
    this.color = Colors.white,
    this.boxSize = 40,
  });

  final IconData icon;
  final double size;
  final VoidCallback onTap;
  final String tooltip;
  final Color color;
  final double boxSize;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        radius: boxSize * 0.5,
        child: SizedBox(
          width: boxSize,
          height: boxSize,
          child: Icon(icon, size: size, color: color),
        ),
      ),
    );
  }
}

class _RepeatButton extends ConsumerWidget {
  const _RepeatButton({required this.mode});

  final RepeatMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = mode == RepeatMode.off
        ? context.appTheme.headerTextMuted
        : context.appTheme.gradientStart;
    return Tooltip(
      message: 'Repeat',
      child: InkResponse(
        onTap: () {
          HapticFeedback.selectionClick();
          ref.read(playerControllerProvider.notifier).cycleRepeat();
        },
        radius: 19,
        child: SizedBox(
          width: 38,
          height: 38,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 8,
                top: 9,
                child: Icon(
                  mode == RepeatMode.one ? Icons.repeat_one : Icons.repeat,
                  color: color,
                  size: 20,
                ),
              ),
              if (mode == RepeatMode.all)
                Positioned(
                  right: 4,
                  top: 2,
                  child: Icon(
                    Icons.circle,
                    size: 6,
                    color: context.appTheme.gradientStart,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayPauseButton extends ConsumerWidget {
  const _PlayPauseButton({required this.playing});

  final bool playing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Tooltip(
      message: playing ? 'Pause' : 'Play',
      child: InkResponse(
        onTap: () {
          HapticFeedback.mediumImpact();
          ref.read(playerControllerProvider.notifier).togglePlayPause();
        },
        radius: 30,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) => ScaleTransition(
            scale: animation,
            child: FadeTransition(opacity: animation, child: child),
          ),
          child: Container(
            key: ValueKey(playing),
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
              key: ValueKey('playicon-$playing'),
              color: Colors.black,
              size: 34,
            ),
          ),
        ),
      ),
    );
  }
}