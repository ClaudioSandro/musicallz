import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/utils/app_gaps.dart';
import '../../../core/widgets/player_bottom_shell.dart';
import '../../../features/library/presentation/providers/library_index_provider.dart';
import '../../../features/library/presentation/widgets/album_card.dart';
import '../../../features/library/presentation/widgets/artist_card.dart';
import '../../../features/player/presentation/providers/player_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/song_list_tile.dart';

/// Shows the songs, albums and artists that belong to one genre.
class GenreDetailScreen extends ConsumerWidget {
  const GenreDetailScreen({super.key, required this.genreName});

  final String genreName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final index = ref.watch(libraryIndexProvider);

    if (index == null) {
      return PlayerBottomShell(
        child: Scaffold(
          appBar: AppBar(),
          body: const EmptyState(
            icon: Icons.category_outlined,
            title: 'Genre not available',
            message: 'Your library is still loading.',
          ),
        ),
      );
    }

    final songs = index.songsForGenre(genreName);
    final albums = index.albumsForGenre(genreName);
    final artists = index.artistsForGenre(genreName);

    if (songs.isEmpty) {
      return PlayerBottomShell(
        child: Scaffold(
          appBar: AppBar(),
          body: EmptyState(
            icon: Icons.category_outlined,
            title: genreName,
            message: 'No songs found for this genre.',
          ),
        ),
      );
    }

    return PlayerBottomShell(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 200,
              backgroundColor: theme.colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.lerp(AppColors.accent, Colors.black, 0.4)!,
                        Colors.black.withValues(alpha: 0.4),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppDimens.pagePadding,
                        AppDimens.pagePadding,
                        AppDimens.pagePadding,
                        24,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GÉNERO',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            genreName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.headlineLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${songs.length} canción'
                            '${songs.length == 1 ? '' : 'es'} · '
                            '${albums.length} álbum'
                            '${albums.length == 1 ? '' : 'es'} · '
                            '${artists.length} artista'
                            '${artists.length == 1 ? '' : 's'}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimens.pagePadding,
                      ),
                      child: SectionHeader(title: 'Canciones'),
                    ),
                    gap8,
                    ...songs.map(
                      (song) => SongListTile(
                        song: song,
                        queue: songs,
                        onTap: () => ref
                            .read(playerControllerProvider.notifier)
                            .playQueue(songs, startIndex: songs.indexOf(song)),
                      ),
                    ),
                    if (albums.isNotEmpty) ...[
                      gap24,
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimens.pagePadding,
                        ),
                        child: SectionHeader(title: 'Álbumes'),
                      ),
                      gap12,
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.pagePadding,
                        ),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.9,
                          ),
                          itemCount: albums.length,
                          itemBuilder: (context, index) => AlbumCard(
                            album: albums[index],
                            onTap: () => context.push('/album/${albums[index].id}'),
                          ),
                        ),
                      ),
                    ],
                    if (artists.isNotEmpty) ...[
                      gap24,
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimens.pagePadding,
                        ),
                        child: SectionHeader(title: 'Artistas'),
                      ),
                      gap12,
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.pagePadding,
                        ),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.9,
                          ),
                          itemCount: artists.length,
                          itemBuilder: (context, index) => ArtistCard(
                            artist: artists[index],
                            onTap: () =>
                                context.push('/artist/${artists[index].id}'),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: AppDimens.pagePadding),
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
