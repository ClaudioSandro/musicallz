import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/favorite_button.dart';
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
      color: Theme.of(context).colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/now-playing'),
        child: Column(
          children: [
            // Live progress bar. The fraction comes from the player position
            // stream (clamped to [0,1]) and is tweened so it fills smoothly
            // instead of jumping between stream ticks.
            Container(
              height: 3,
              width: double.infinity,
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              alignment: Alignment.centerLeft,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: fraction, end: fraction),
                duration: const Duration(milliseconds: 250),
                curve: Curves.linear,
                builder: (context, value, child) => FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value,
                  child: child,
                ),
                child: ColoredBox(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            Container(
              height: 62,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Row(
                children: [
                  Hero(
                    tag: 'song-art-${song.id}',
                    child: CoverArt(
                      bytes: song.albumArt,
                      filePath: song.albumArtPath,
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
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  FavoriteButton(songId: song.id, size: 22),
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
    final fg = Theme.of(context).colorScheme.onSurface;
    return IconButton(
      onPressed: () {
        HapticFeedback.selectionClick();
        ctrl.togglePlayPause();
      },
      icon: Icon(
        playing ? Icons.pause_circle_filled : Icons.play_circle_filled,
        color: fg,
        size: 34,
      ),
      tooltip: playing ? 'Pausa' : 'Reproducir',
    );
  }
}

class _NextButton extends ConsumerWidget {
  const _NextButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fg = Theme.of(context).colorScheme.onSurface;
    return IconButton(
      onPressed: () =>
          ref.read(playerControllerProvider.notifier).next(),
      icon: Icon(Icons.skip_next, color: fg, size: 30),
      tooltip: 'Siguiente',
    );
  }
}