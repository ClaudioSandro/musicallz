import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_gaps.dart';
import '../../../../core/widgets/player_bottom_shell.dart';
import '../../../../features/playlists/presentation/providers/playlist_providers.dart';
import '../../../../features/playlists/presentation/widgets/playlist_tile.dart'
    show formatPlaylistDuration;
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/song_list_tile.dart';
import '../../../player/presentation/providers/player_providers.dart';
import '../../domain/services/library_index.dart';
import '../providers/library_prefs_provider.dart';
import '../widgets/sort_menu_button.dart';

class LikedSongsScreen extends ConsumerWidget {
  const LikedSongsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songs = ref.watch(likedSongsProvider);
    final prefs = ref.watch(libraryPrefsProvider);
    final sorted = sortSongs(songs, prefs.likedSort);
    final totalDuration = songs.fold<Duration>(
      Duration.zero,
      (acc, song) => acc + song.duration,
    );

    return PlayerBottomShell(
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LikedHeader(
                count: songs.length,
                totalDuration: totalDuration,
                onPlay: () => ref
                    .read(playerControllerProvider.notifier)
                    .playQueue(sorted),
                onShuffle: () async {
                  final ctrl = ref.read(playerControllerProvider.notifier);
                  await ctrl.applyAudioShuffle(true);
                  await ctrl.playQueue(sorted);
                },
                sortButton: SortMenuButton<SongsSort>(
                  options: const [
                    (value: SongsSort.titleAsc, label: 'Título (A→Z)', icon: Icons.sort_by_alpha),
                    (value: SongsSort.titleDesc, label: 'Título (Z→A)', icon: Icons.sort_by_alpha),
                    (value: SongsSort.artistAsc, label: 'Artista', icon: Icons.person_outline),
                    (value: SongsSort.albumAsc, label: 'Álbum', icon: Icons.album_outlined),
                    (value: SongsSort.addedNew, label: 'Añadidas recientemente', icon: Icons.add_circle_outline),
                    (value: SongsSort.addedOld, label: 'Añadidas hace más', icon: Icons.history),
                    (value: SongsSort.yearNew, label: 'Año (nuevas)', icon: Icons.calendar_today_outlined),
                    (value: SongsSort.yearOld, label: 'Año (viejas)', icon: Icons.calendar_today_outlined),
                    (value: SongsSort.durationLong, label: 'Duración (más largas)', icon: Icons.timer_outlined),
                    (value: SongsSort.durationShort, label: 'Duración (más cortas)', icon: Icons.timer_outlined),
                    (value: SongsSort.mostPlayed, label: 'Más reproducidas', icon: Icons.trending_up),
                  ],
                  selected: prefs.likedSort,
                  onSelected: (v) =>
                      ref.read(libraryPrefsProvider.notifier).setLikedSort(v),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: songs.isEmpty
                    ? const EmptyState(
                        icon: Icons.favorite_border,
                        title: 'Aún no hay canciones que te gusten',
                        message:
                            'Toca el corazón en cualquier canción para guardarla aquí.',
                      )
                    : ListView.builder(
                        itemCount: sorted.length,
                        itemBuilder: (context, index) {
                          final song = sorted[index];
                          return SongListTile(
                            song: song,
                            queue: sorted,
                            onTap: () => ref
                                .read(playerControllerProvider.notifier)
                                .playQueue(sorted, startIndex: index),
                          );
                        },
                      ),
              ),
            ],
          ),
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
    required this.sortButton,
  });

  final int count;
  final Duration totalDuration;
  final VoidCallback onPlay;
  final VoidCallback onShuffle;
  final Widget sortButton;

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
                tooltip: 'Atrás',
              ),
              const Spacer(),
              sortButton,
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
                      'Canciones que me gustan',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      count == 0
                          ? 'Canciones que te gustan'
                          : '$count ${count == 1 ? 'canción' : 'canciones'} · '
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
                tooltip: 'Reproducir',
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
              gap12,
              IconButton(
                onPressed: onShuffle,
                icon: Icon(
                  Icons.shuffle,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                tooltip: 'Aleatorio',
              ),
            ],
          ),
        ],
      ),
    );
  }
}