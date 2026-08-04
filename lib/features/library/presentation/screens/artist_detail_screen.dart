import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/utils/app_gaps.dart';
import '../../../../features/player/presentation/providers/player_providers.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/song_list_tile.dart';
import '../../domain/entities/artist.dart';
import '../providers/library_index_provider.dart';
import '../widgets/cover_art.dart';

class ArtistDetailScreen extends ConsumerWidget {
  const ArtistDetailScreen({super.key, required this.artistId});

  final String artistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artist = ref.watch(artistProvider(artistId));

    if (artist == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyState(
          icon: Icons.person_off_outlined,
          title: 'Artist not found',
          message: 'This artist is no longer available in your library.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppDimens.pagePadding),
        children: [
          _ArtistHeader(
            artist: artist,
            onPlay: () => ref.read(playerControllerProvider.notifier)
                .playQueue(artist.songs),
          ),
          gap8,
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppDimens.pagePadding),
            child: SectionHeader(title: 'Songs'),
          ),
          gap8,
          ...artist.songs.map(
            (song) => SongListTile(
              song: song,
              onTap: () => ref.read(playerControllerProvider.notifier)
                  .playQueue(artist.songs,
                      startIndex: artist.songs.indexOf(song)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArtistHeader extends StatelessWidget {
  const _ArtistHeader({required this.artist, required this.onPlay});

  final Artist artist;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppDimens.pagePadding),
      child: Row(
        children: [
          CoverArt(
            bytes: artist.coverArt,
            size: 96,
            circular: true,
            icon: Icons.person,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artist.name,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                gap4,
                Text(
                  '${artist.songCount} canciones · ${artist.albumCount} álbumes',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                gap12,
                IconButton.filled(
                  onPressed: onPlay,
                  icon: const Icon(Icons.play_arrow, size: 28),
                  tooltip: 'Play artist',
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