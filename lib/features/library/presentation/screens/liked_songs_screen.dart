import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_gaps.dart';
import '../../../../features/playlists/presentation/providers/playlist_providers.dart';
import '../../../../features/playlists/presentation/widgets/playlist_tile.dart'
    show formatPlaylistDuration;
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/song_list_tile.dart';
import '../../../player/presentation/providers/player_providers.dart';

class LikedSongsScreen extends ConsumerWidget {
  const LikedSongsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songs = ref.watch(likedSongsProvider);
    final totalDuration = songs.fold<Duration>(
      Duration.zero,
      (acc, song) => acc + song.duration,
    );

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LikedHeader(
              count: songs.length,
              totalDuration: totalDuration,
              onPlay: () => ref
                  .read(playerControllerProvider.notifier)
                  .playQueue(songs),
              onShuffle: () async {
                final ctrl = ref.read(playerControllerProvider.notifier);
                await ctrl.applyAudioShuffle(true);
                await ctrl.playQueue(songs);
              },
            ),
            const Divider(height: 1, color: Colors.white12),
            Expanded(
              child: songs.isEmpty
                  ? const EmptyState(
                      icon: Icons.favorite_border,
                      title: 'No Liked Songs yet',
                      message: 'Tap the heart on any song to save it here.',
                    )
                  : ListView.builder(
                      itemCount: songs.length,
                      itemBuilder: (context, index) {
                        final song = songs[index];
                        return SongListTile(
                          song: song,
                          queue: songs,
                          onTap: () => ref
                              .read(playerControllerProvider.notifier)
                              .playQueue(songs, startIndex: index),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LikedHeader extends StatelessWidget {
  const _LikedHeader({
    required this.count,
    required this.totalDuration,
    required this.onPlay,
    required this.onShuffle,
  });

  final int count;
  final Duration totalDuration;
  final VoidCallback onPlay;
  final VoidCallback onShuffle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Back',
              ),
              const Spacer(),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF7C4DFF),
                      Color(0xFF9C27B0),
                      Color(0xFF2979FF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.favorite, color: Colors.white, size: 72),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Liked Songs',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      count == 0
                          ? 'Songs you like'
                          : '$count song${count == 1 ? '' : 's'} · '
                              '${formatPlaylistDuration(totalDuration)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton.filled(
                onPressed: onPlay,
                icon: const Icon(Icons.play_arrow, size: 30),
                tooltip: 'Play',
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.black,
                ),
              ),
              gap12,
              IconButton(
                onPressed: onShuffle,
                icon: const Icon(Icons.shuffle, color: Colors.white),
                tooltip: 'Shuffle',
              ),
            ],
          ),
        ],
      ),
    );
  }
}