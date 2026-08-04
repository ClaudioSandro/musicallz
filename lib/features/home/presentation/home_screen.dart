import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimens.dart';
import '../../../core/utils/app_gaps.dart';
import '../../../features/library/domain/entities/song.dart';
import '../../../features/library/domain/exceptions/music_library_exceptions.dart';
import '../../../features/library/presentation/providers/library_index_provider.dart';
import '../../../features/library/presentation/providers/music_library_provider.dart';
import '../../../features/library/presentation/widgets/horizontal_album_card.dart';
import '../../../features/library/presentation/widgets/horizontal_artist_card.dart';
import '../../../features/player/presentation/providers/player_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_state.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/song_list_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const int _recentLimit = 5;
  static const int _topArtistsLimit = 6;
  static const int _albumsLimit = 6;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final library = ref.watch(musicLibraryProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.pagePadding,
                AppDimens.pagePadding,
                AppDimens.pagePadding,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Musicallz',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.accent,
                    ),
                  ),
                  Text(
                    'Bienvenido, tu música local te espera.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            gap16,
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: library.when(
                  loading: () =>
                      const LoadingState(message: 'Scanning your music...'),
                  error: (error, stackTrace) => ErrorState(
                    message: describeLibraryError(error),
                    onRetry: () =>
                        ref.read(musicLibraryProvider.notifier).refresh(),
                  ),
                  data: (songs) => songs.isEmpty
                      ? const EmptyState(
                          icon: Icons.library_music_outlined,
                          title: 'No songs found yet',
                          message: 'Create the folder Music/MusicallzStorage '
                              'and place MP3 files inside it.',
                        )
                      : _HomeContent(songs: songs),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeContent extends ConsumerWidget {
  const _HomeContent({required this.songs});

  final List<Song> songs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentStart = songs.length > HomeScreen._recentLimit
        ? songs.length - HomeScreen._recentLimit
        : 0;
    final recent = songs.sublist(recentStart).reversed.toList();

    final artists = ref.watch(artistsProvider);
    final albums = ref.watch(albumsProvider);

    return ListView(
      padding: const EdgeInsets.only(bottom: AppDimens.pagePadding),
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimens.pagePadding),
          child: SectionHeader(title: 'Recently Added'),
        ),
        gap8,
        ...recent.map(
          (song) => SongListTile(
            song: song,
            onTap: () => ref.read(playerControllerProvider.notifier)
                .playQueue(songs, startIndex: songs.indexOf(song)),
          ),
        ),
        if (artists.isNotEmpty) ...[
          gap24,
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppDimens.pagePadding),
            child: SectionHeader(title: 'Top Artists'),
          ),
          gap12,
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.pagePadding,
              ),
              itemCount: artists.length > HomeScreen._topArtistsLimit
                  ? HomeScreen._topArtistsLimit
                  : artists.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final artist = artists[index];
                return HorizontalArtistCard(
                  artist: artist,
                  onTap: () => context.push('/artist/${artist.id}'),
                );
              },
            ),
          ),
        ],
        if (albums.isNotEmpty) ...[
          gap24,
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppDimens.pagePadding),
            child: SectionHeader(title: 'Albums'),
          ),
          gap12,
          SizedBox(
            height: 190,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.pagePadding,
              ),
              itemCount: albums.length > HomeScreen._albumsLimit
                  ? HomeScreen._albumsLimit
                  : albums.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(width: 16),
              itemBuilder: (context, index) {
                final album = albums[index];
                return HorizontalAlbumCard(
                  album: album,
                  onTap: () => context.push('/album/${album.id}'),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}