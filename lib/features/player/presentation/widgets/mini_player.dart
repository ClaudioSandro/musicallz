import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_gaps.dart';
import '../../../library/domain/entities/song.dart';
import '../../../library/presentation/widgets/cover_art.dart';
import '../providers/player_providers.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final song = ref.watch(currentSongProvider);
    final hasSong = ref.watch(hasActiveSongProvider);

    if (!hasSong || song == null) return const SizedBox.shrink();

    return Material(
      color: AppColors.surface,
      child: InkWell(
        onTap: () => context.push('/now-playing'),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.surfaceHigh)),
          ),
          child: Row(
            children: [
              CoverArt(
                bytes: song.albumArt,
                size: 44,
                radius: 6,
              ),
              gap12,
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      song.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              _PlayPauseButton(song: song),
              _NextButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayPauseButton extends ConsumerWidget {
  const _PlayPauseButton({required this.song});

  final Song song;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playing = ref.watch(isPlayingProvider);
    return IconButton(
      onPressed: () =>
          ref.read(playerControllerProvider.notifier).togglePlayPause(),
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