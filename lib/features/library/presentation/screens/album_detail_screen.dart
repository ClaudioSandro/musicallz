import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/utils/app_gaps.dart';
import '../../../../core/utils/format_duration.dart';
import '../../../../core/widgets/player_bottom_shell.dart';
import '../../../../features/player/presentation/providers/player_providers.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/song_list_tile.dart';
import '../../domain/entities/album.dart';
import '../providers/album_favorites_provider.dart';
import '../providers/library_index_provider.dart';
import '../widgets/cover_art.dart';

class AlbumDetailScreen extends ConsumerWidget {
  const AlbumDetailScreen({super.key, required this.albumId});

  final String albumId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final album = ref.watch(albumProvider(albumId));
    final songs = ref.watch(albumSongsProvider(albumId));

    if (album == null) {
      return PlayerBottomShell(
        child: Scaffold(
          appBar: AppBar(),
          body: const EmptyState(
            icon: Icons.album_outlined,
            title: 'Album not found',
            message: 'This album is no longer available in your library.',
          ),
        ),
      );
    }

    final totalDuration = songs.fold<Duration>(
      Duration.zero,
      (acc, song) => acc + song.duration,
    );

    final headerImage = CoverArt(
      bytes: album.coverArt,
      filePath: album.coverArtPath,
      size: 220,
      radius: 20,
    );

    return PlayerBottomShell(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 340,
              backgroundColor: theme.colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: _AlbumHeader(
                  album: album,
                  totalDuration: totalDuration,
                  onPlay: () => ref.read(playerControllerProvider.notifier)
                      .playQueue(songs),
                  heroImage: headerImage,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.pagePadding,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Songs',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    gap8,
                    ...songs.map(
                      (song) => SongListTile(
                        song: song,
                        queue: songs,
                        onTap: () => ref.read(playerControllerProvider.notifier)
                            .playQueue(songs,
                                startIndex: songs.indexOf(song)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The detail header uses the full gradient overlay plus the cover art.
class _AlbumHeader extends ConsumerWidget {
  const _AlbumHeader({
    required this.album,
    required this.totalDuration,
    required this.onPlay,
    required this.heroImage,
  });

  final Album album;
  final Duration totalDuration;
  final VoidCallback onPlay;
  final Widget heroImage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final saved = ref.watch(albumFavoritesProvider).contains(album.id);
    final subtitle = [
      if (album.year != null) '${album.year}',
      '${album.songCount} canciones',
      'Duración total ${formatDuration(totalDuration)}',
    ].join(' · ');

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.lerp(theme.colorScheme.primary, Colors.black, 0.55)!,
                Colors.black.withValues(alpha: 0.35),
              ],
            ),
          ),
        ),
        // SafeArea keeps the content below the status bar on edge-to-edge
        // displays; Align.topCenter centers the cover horizontally.
        SafeArea(
          bottom: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.pagePadding,
                AppDimens.pagePadding,
                AppDimens.pagePadding,
                16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Subtle entrance animation on the cover; TweenAnimationBuilder
                  // is stateless and safe to rebuild (no Hero/IndexedStack clash).
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.92, end: 1),
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) =>
                        Opacity(opacity: value, child: Transform.scale(scale: value, child: child)),
                    child: heroImage,
                  ),
                  gap16,
                  Text(
                    album.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  gap4,
                  Text(
                    album.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  gap4,
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  gap16,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filled(
                        onPressed: onPlay,
                        icon: const Icon(Icons.play_arrow, size: 28),
                        tooltip: 'Play album',
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.black,
                        ),
                      ),
                      gap12,
                      IconButton(
                        onPressed: () => ref
                            .read(albumFavoritesProvider.notifier)
                            .toggle(album.id),
                        icon: Icon(
                          saved ? Icons.favorite : Icons.favorite_border,
                          color: saved ? Colors.redAccent : Colors.white,
                        ),
                        tooltip: saved ? 'Remove from saved' : 'Save album',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
