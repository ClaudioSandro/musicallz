import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/utils/app_gaps.dart';
import '../../../../features/player/presentation/providers/player_providers.dart';
import '../../../../features/playlists/presentation/providers/playlist_providers.dart';
import '../../../../features/playlists/presentation/widgets/playlist_dialog.dart';
import '../../../../features/playlists/presentation/widgets/playlist_tile.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_state.dart';
import '../../../../shared/widgets/song_list_tile.dart';
import '../../domain/exceptions/music_library_exceptions.dart';
import '../providers/library_index_provider.dart';
import '../providers/music_library_provider.dart';
import '../widgets/album_tile.dart';
import '../widgets/artist_tile.dart';
import '../widgets/library_tab_header.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final library = ref.watch(musicLibraryProvider);
    final isRefreshing = library.isLoading;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimens.pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Library',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  gap16,
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          library.hasValue
                              ? '${library.value!.length} canciones'
                              : 'Tu música local',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: isRefreshing
                            ? null
                            : () => ref.read(musicLibraryProvider.notifier)
                                .refresh(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Rescan Library'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
                          message:
                              'Create the folder Music/MusicallzStorage '
                              'and place MP3 files inside it.',
                        )
                      : DefaultTabController(
                          length: 4,
                          child: Column(
                            children: [
                              _LibraryTabBar(theme: theme),
                              const Expanded(
                                child: TabBarView(
                                  children: [
                                    _PlaylistsView(),
                                    _ArtistsView(),
                                    _AlbumsView(),
                                    _SongsView(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryTabBar extends StatelessWidget {
  const _LibraryTabBar({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return TabBar(
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      labelColor: Colors.white,
      unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
      indicatorColor: theme.colorScheme.primary,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle:
          theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      dividerColor: Colors.transparent,
      tabs: const [
        Tab(text: 'Playlists'),
        Tab(text: 'Artists'),
        Tab(text: 'Albums'),
        Tab(text: 'Songs'),
      ],
    );
  }
}

class _PlaylistsView extends ConsumerWidget {
  const _PlaylistsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final favoritesRepo = ref.read(playlistRepositoryProvider);

    return ref.watch(playlistsProvider).when(
          skipLoadingOnRefresh: true,
          loading: () => const LoadingState(message: 'Loading playlists...'),
          error: (error, _) => ErrorState(
            message: '$error',
            onRetry: () => ref.invalidate(playlistsProvider),
          ),
          data: (playlists) {
            final likedCount =
                ref.watch(favoriteSongIdsProvider).valueOrNull?.length ?? 0;
            return ListView(
              padding:
                  const EdgeInsets.only(bottom: AppDimens.pagePadding),
              children: [
                LibraryTabHeader(
                  title: 'Playlists',
                  count: playlists.length,
                ),
                ListTile(
                  onTap: () async {
                    final draft = await showPlaylistDialog(
                      context,
                      title: 'New Playlist',
                      confirmLabel: 'Create',
                    );
                    if (draft == null || !context.mounted) return;
                    await favoritesRepo.createPlaylist(
                      draft.name,
                      description: draft.description.isEmpty
                          ? null
                          : draft.description,
                    );
                  },
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                  title: const Text(
                    'Create Playlist',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    'Start a fresh collection',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                ListTile(
                  onTap: () => context.push('/liked-songs'),
                  leading: Container(
                    width: 48,
                    height: 48,
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
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.favorite, color: Colors.white),
                  ),
                  title: const Text(
                    'Liked Songs',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    likedCount == 0
                        ? 'Songs you like will appear here'
                        : '$likedCount song${likedCount == 1 ? '' : 's'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (playlists.isEmpty) ...[
                  gap8,
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Your playlists will appear here.',
                      style: TextStyle(color: Colors.white60),
                    ),
                  ),
                ] else ...[
                  gap8,
                  ...playlists.map(
                    (playlist) => PlaylistTile(
                      playlist: playlist,
                      onTap: () =>
                          context.push('/playlist/${playlist.id}'),
                    ),
                  ),
                ],
              ],
            );
          },
        );
  }
}

class _ArtistsView extends ConsumerWidget {
  const _ArtistsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final artists = ref.watch(artistsProvider);
    if (artists.isEmpty) {
      return const EmptyState(
        icon: Icons.person_outline,
        title: 'No artists yet',
        message: 'Your artists will appear here once you add music.',
      );
    }
    return ListView(
      padding: const EdgeInsets.only(bottom: AppDimens.pagePadding),
      children: [
        LibraryTabHeader(title: 'Artists', count: artists.length),
        ...artists.map(
          (artist) => ArtistTile(
            artist: artist,
            onTap: () => context.push('/artist/${artist.id}'),
          ),
        ),
      ],
    );
  }
}

class _AlbumsView extends ConsumerWidget {
  const _AlbumsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albums = ref.watch(albumsProvider);
    if (albums.isEmpty) {
      return const EmptyState(
        icon: Icons.album_outlined,
        title: 'No albums yet',
        message: 'Your albums will appear here when you add music.',
      );
    }
    return ListView(
      padding: const EdgeInsets.only(bottom: AppDimens.pagePadding),
      children: [
        LibraryTabHeader(title: 'Albums', count: albums.length),
        ...albums.map(
          (album) => AlbumTile(
            album: album,
            onTap: () => context.push('/album/${album.id}'),
          ),
        ),
      ],
    );
  }
}

class _SongsView extends ConsumerWidget {
  const _SongsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(musicLibraryProvider);
    final songs = library.value ?? const [];
    if (songs.isEmpty) {
      return const EmptyState(
        icon: Icons.music_note,
        title: 'No songs yet',
        message: 'Your songs will appear here when you add music.',
      );
    }
    return ListView(
      padding: const EdgeInsets.only(bottom: AppDimens.pagePadding),
      children: [
        LibraryTabHeader(title: 'Songs', count: songs.length),
        ...songs.map(
          (song) => SongListTile(
            song: song,
            onTap: () => ref.read(playerControllerProvider.notifier)
                .playQueue(songs, startIndex: songs.indexOf(song)),
          ),
        ),
      ],
    );
  }
}