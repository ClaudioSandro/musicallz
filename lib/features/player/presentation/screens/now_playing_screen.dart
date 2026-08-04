import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_gaps.dart';
import '../../../../core/utils/format_duration.dart';
import '../../../library/presentation/widgets/cover_art.dart';
import '../../domain/models/player_state.dart';
import '../providers/player_providers.dart';

class NowPlayingScreen extends ConsumerStatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  ConsumerState<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends ConsumerState<NowPlayingScreen> {
  double? _dragMs;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final song = ref.watch(currentSongProvider);
    final playing = ref.watch(isPlayingProvider);
    final position = ref.watch(currentPositionProvider);
    final duration = ref.watch(totalDurationProvider);
    final shuffle = ref.watch(shuffleStateProvider);
    final repeat = ref.watch(repeatStateProvider);

    final displayMs = (_dragMs ?? position.inMilliseconds.toDouble())
        .clamp(0.0, duration.inMilliseconds.toDouble())
        .toDouble();
    final displayPos = Duration(milliseconds: displayMs.round());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.keyboard_arrow_down,
                        color: AppColors.textSecondary),
                  ),
                  const Expanded(
                    child: Text(
                      'Musicallz',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: KeyedSubtree(
                        key: ValueKey(song?.id ?? 'none'),
                        child: CoverArt(
                          bytes: song?.albumArt,
                          size: 340,
                          radius: 28,
                        ),
                      ),
                    ),
                    const Spacer(),
                    _TitleBlock(
                      key: ValueKey(song?.id ?? 'none'),
                      title: song?.title ?? '',
                      artist: song?.artist ?? '',
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Slider(
                    value: displayMs,
                    max: duration.inMilliseconds.toDouble().clamp(1, double.infinity).toDouble(),
                    activeColor: AppColors.accent,
                    inactiveColor: AppColors.surfaceHigh,
                    onChangeStart: (_) => setState(() => _dragMs = displayMs),
                    onChanged: (v) => setState(() => _dragMs = v),
                    onChangeEnd: (v) {
                      ref
                          .read(playerControllerProvider.notifier)
                          .seekTo(Duration(milliseconds: v.round()));
                      setState(() => _dragMs = null);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatDuration(displayPos),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        '-${formatDuration(duration - displayPos > Duration.zero ? duration - displayPos : Duration.zero)}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  gap16,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ShuffleButton(enabled: shuffle),
                      _SkipButton(
                        icon: Icons.skip_previous,
                        isPrevious: true,
                      ),
                      _PlayPauseButton(playing: playing),
                      _SkipButton(
                        icon: Icons.skip_next,
                        isPrevious: false,
                      ),
                      _RepeatButton(mode: repeat),
                    ],
                  ),
                  gap24,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({
    super.key,
    required this.title,
    required this.artist,
  });

  final String title;
  final String artist;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          gap4,
          Text(
            artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShuffleButton extends ConsumerWidget {
  const _ShuffleButton({required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = enabled ? AppColors.accent : AppColors.textSecondary;
    return IconButton(
      onPressed: () =>
          ref.read(playerControllerProvider.notifier).toggleShuffle(),
      icon: Icon(Icons.shuffle, color: color, size: 26),
      tooltip: 'Shuffle',
    );
  }
}

class _SkipButton extends ConsumerWidget {
  const _SkipButton({required this.icon, required this.isPrevious});

  final IconData icon;
  final bool isPrevious;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () {
        final ctrl = ref.read(playerControllerProvider.notifier);
        if (isPrevious) {
          ctrl.previous();
        } else {
          ctrl.next();
        }
      },
      icon: Icon(icon, color: Colors.white, size: 30),
      tooltip: isPrevious ? 'Previous' : 'Next',
    );
  }
}

class _PlayPauseButton extends ConsumerWidget {
  const _PlayPauseButton({required this.playing});

  final bool playing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () =>
          ref.read(playerControllerProvider.notifier).togglePlayPause(),
      icon: Icon(
        playing ? Icons.pause_circle_filled : Icons.play_circle_filled,
        color: Colors.white,
        size: 72,
      ),
      tooltip: playing ? 'Pause' : 'Play',
    );
  }
}

class _RepeatButton extends ConsumerWidget {
  const _RepeatButton({required this.mode});

  final RepeatMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = mode == RepeatMode.off ? AppColors.textSecondary : AppColors.accent;
    return IconButton(
      onPressed: () => ref.read(playerControllerProvider.notifier).cycleRepeat(),
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            mode == RepeatMode.one ? Icons.repeat_one : Icons.repeat,
            color: color,
            size: 26,
          ),
          if (mode == RepeatMode.all)
            const Positioned(
              right: 0,
              top: 0,
              child: Icon(Icons.circle, size: 8, color: AppColors.accent),
            ),
        ],
      ),
      tooltip: 'Repeat',
    );
  }
}