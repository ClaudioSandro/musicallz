import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/utils/app_gaps.dart';
import '../../../../core/utils/format_duration.dart';
import '../../../../features/player/presentation/providers/player_providers.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/song_list_tile.dart';
import '../../domain/entities/album.dart';
import '../providers/library_index_provider.dart';
import '../widgets/cover_art.dart';

class AlbumDetailScreen extends ConsumerWidget {
  const AlbumDetailScreen({super.key, required this.albumId});

  final String albumId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final album = ref.watch(albumProvider(albumId));
    final songs = ref.watch(albumSongsProvider(albumId));

    if (album == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.album_outlined,
          title: 'Album not found',
          message: 'This album is no longer available in your library.',
        ),
      );
    }

    final totalDuration = songs.fold<Duration>(
      Duration.zero,
      (acc, song) => acc + song.duration,
    );

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppDimens.pagePadding),
        children: [
          _AlbumHeader(
            album: album,
            totalDuration: totalDuration,
            onPlay: () => ref.read(playerControllerProvider.notifier)
                .playQueue(songs),
          ),
          gap8,
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppDimens.pagePadding),
            child: SectionHeader(title: 'Songs'),
          ),
          gap8,
          ...songs.map(
            (song) => SongListTile(
              song: song,
              onTap: () => ref.read(playerControllerProvider.notifier)
                  .playQueue(songs, startIndex: songs.indexOf(song)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlbumHeader extends StatelessWidget {
  const _AlbumHeader({
    required this.album,
    required this.totalDuration,
    required this.onPlay,
  });

  final Album album;
  final Duration totalDuration;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = [
      if (album.year != null) '${album.year}',
      '${album.songCount} canciones',
      'Duración total ${formatDuration(totalDuration)}',
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.all(AppDimens.pagePadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CoverArt(bytes: album.coverArt, size: 120, radius: 12),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  album.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                gap4,
                Text(
                  album.artist,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                gap4,
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                gap12,
                IconButton.filled(
                  onPressed: onPlay,
                  icon: const Icon(Icons.play_arrow, size: 28),
                  tooltip: 'Play album',
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}