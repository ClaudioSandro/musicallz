import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/marquee_text.dart';
import '../../../library/presentation/widgets/cover_art.dart';
import '../providers/player_providers.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final song = ref.watch(currentSongProvider);
    final hasSong = ref.watch(hasActiveSongProvider);

    if (!hasSong || song == null) return const SizedBox.shrink();

    final position = ref.watch(currentPositionProvider);
    final duration = ref.watch(totalDurationProvider);
    final fraction = duration > Duration.zero
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/now-playing'),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 2,
              width: double.infinity,
              color: AppColors.surfaceHigh,
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: fraction,
                child: const ColoredBox(color: AppColors.accent),
              ),
            ),
            Container(
              height: 62,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: const BoxDecoration(
                color: AppColors.surface,
              ),
              child: Row(
                children: [
                  Hero(
                    tag: 'song-art-${song.id}',
                    child: CoverArt(
                      bytes: song.albumArt,
                      size: 44,
                      radius: 6,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MarqueeText(
                          song.title,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          song.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  _PlayPauseButton(),
                  _NextButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayPauseButton extends ConsumerWidget {
  const _PlayPauseButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playing = ref.watch(isPlayingProvider);
    final ctrl = ref.read(playerControllerProvider.notifier);
    return IconButton(
      onPressed: () {
        HapticFeedback.selectionClick();
        ctrl.togglePlayPause();
      },
      icon: Icon(
        playing ? Icons.pause_circle_filled : Icons.play_circle_filled,
        color: Colors.white,
        size: 34,
      ),
      tooltip: playing ? 'Pause' : 'Play',
    );
  }
}

class _NextButton extends ConsumerWidget {
  const _NextButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () =>
          ref.read(playerControllerProvider.notifier).next(),
      icon: const Icon(Icons.skip_next, color: Colors.white, size: 30),
      tooltip: 'Next',
    );
  }
}