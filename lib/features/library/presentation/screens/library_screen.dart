import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/utils/app_gaps.dart';
import '../../../../features/player/presentation/providers/player_providers.dart';
import '../../../../features/playlists/domain/services/playlist_sort.dart';
import '../../../../features/playlists/presentation/providers/playlist_providers.dart';
import '../../../../features/playlists/presentation/widgets/playlist_card.dart';
import '../../../../features/playlists/presentation/widgets/playlist_dialog.dart';
import '../../../../features/playlists/presentation/widgets/playlist_tile.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/loading_state.dart';
import '../../../../shared/widgets/song_list_tile.dart';
import '../../domain/exceptions/music_library_exceptions.dart';
import '../../domain/services/library_index.dart';
import '../providers/library_index_provider.dart';
import '../providers/library_prefs_provider.dart';
import '../providers/music_library_provider.dart';
import '../widgets/album_card.dart';
import '../widgets/artist_card.dart';
import '../widgets/artist_tile.dart';
import '../widgets/library_tab_header.dart';
import '../widgets/sort_menu_button.dart';
import '../widgets/view_toggle.dart';

const _songSortOptions = <SortOption<SongsSort>>[
  (value: SongsSort.titleAsc, label: 'Título (A→Z)', icon: Icons.sort_by_alpha),
  (value: SongsSort.titleDesc, label: 'Título (Z→A)', icon: Icons.sort_by_alpha),
  (value: SongsSort.artistAsc, label: 'Artista', icon: Icons.person_outline),
  (value: SongsSort.albumAsc, label: 'Álbum', icon: Icons.album_outlined),
  (value: SongsSort.addedNew, label: 'Añadidas recientemente', icon: Icons.add_circle_outline),
  (value: SongsSort.addedOld, label: 'Añadidas hace más', icon: Icons.history),
  (value: SongsSort.modifiedNew, label: 'Modificadas recientemente', icon: Icons.edit_outlined),
  (value: SongsSort.modifiedOld, label: 'Modificadas hace más', icon: Icons.edit_off_outlined),
  (value: SongsSort.yearNew, label: 'Año (nuevas)', icon: Icons.calendar_today_outlined),
  (value: SongsSort.yearOld, label: 'Año (viejas)', icon: Icons.calendar_today_outlined),
  (value: SongsSort.durationLong, label: 'Duración (más largas)', icon: Icons.timer_outlined),
  (value: SongsSort.durationShort, label: 'Duración (más cortas)', icon: Icons.timer_outlined),
  (value: SongsSort.mostPlayed, label: 'Más reproducidas', icon: Icons.trending_up),
];

const _albumSortOptions = <SortOption<AlbumsSort>>[
  (value: AlbumsSort.titleAsc, label: 'Título (A→Z)', icon: Icons.sort_by_alpha),
  (value: AlbumsSort.titleDesc, label: 'Título (Z→A)', icon: Icons.sort_by_alpha),
  (value: AlbumsSort.artistAsc, label: 'Artista', icon: Icons.person_outline),
  (value: AlbumsSort.yearNew, label: 'Año (nuevos)', icon: Icons.calendar_today_outlined),
  (value: AlbumsSort.yearOld, label: 'Año (viejos)', icon: Icons.calendar_today_outlined),
  (value: AlbumsSort.songCount, label: 'Nº de canciones', icon: Icons.music_note_outlined),
  (value: AlbumsSort.mostPlayed, label: 'Más reproducidos', icon: Icons.trending_up),
];

const _artistSortOptions = <SortOption<ArtistsSort>>[
  (value: ArtistsSort.nameAsc, label: 'Nombre (A→Z)', icon: Icons.sort_by_alpha),
  (value: ArtistsSort.nameDesc, label: 'Nombre (Z→A)', icon: Icons.sort_by_alpha),
  (value: ArtistsSort.songCount, label: 'Nº de canciones', icon: Icons.music_note_outlined),
  (value: ArtistsSort.albumCount, label: 'Nº de álbumes', icon: Icons.album_outlined),
  (value: ArtistsSort.mostPlayed, label: 'Más reproducidos', icon: Icons.trending_up),
];

const _playlistSortOptions = <SortOption<PlaylistsSort>>[
  (value: PlaylistsSort.nameAsc, label: 'Nombre (A→Z)', icon: Icons.sort_by_alpha),
  (value: PlaylistsSort.nameDesc, label: 'Nombre (Z→A)', icon: Icons.sort_by_alpha),
  (value: PlaylistsSort.createdNew, label: 'Creadas recientemente', icon: Icons.add_circle_outline),
  (value: PlaylistsSort.createdOld, label: 'Creadas hace más', icon: Icons.history),
  (value: PlaylistsSort.updatedNew, label: 'Actualizadas recientemente', icon: Icons.update),
  (value: PlaylistsSort.updatedOld, label: 'Actualizadas hace más', icon: Icons.history),
  (value: PlaylistsSort.songCount, label: 'Nº de canciones', icon: Icons.music_note_outlined),
];

/// Grid cell aspect ratio that leaves room for the title/subtitle block under
/// a square cover, adapting to the available width and text scale.
double _gridAspect(double width, int columns) {
  final cellWidth =
      (width - AppDimens.pagePadding * 2 - 12.0 * (columns - 1)) / columns;
  final cellHeight = cellWidth + 68;
  return cellWidth / cellHeight;
}

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
                    'Tu biblioteca',
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
                        label: const Text('Volver a escanear'),
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
                      const LoadingState(message: 'Escaneando tu música...'),
                  error: (error, stackTrace) => ErrorState(
                    message: describeLibraryError(error),
                    onRetry: () =>
                        ref.read(musicLibraryProvider.notifier).refresh(),
                  ),
                  data: (songs) => songs.isEmpty
                      ? const EmptyState(
                          icon: Icons.library_music_outlined,
                          title: 'Aún no hay canciones',
                          message:
                              'Crea la carpeta Music/MusicallzStorage '
                              'y coloca archivos MP3 dentro.',
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
      labelColor: theme.colorScheme.onSurface,
      unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
      indicatorColor: theme.colorScheme.primary,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle:
          theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      dividerColor: Colors.transparent,
      tabs: const [
        Tab(text: 'Listas'),
        Tab(text: 'Artistas'),
        Tab(text: 'Álbumes'),
        Tab(text: 'Canciones'),
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
    final prefs = ref.watch(libraryPrefsProvider);
    final likedCount =
        ref.watch(favoriteSongIdsProvider).valueOrNull?.length ?? 0;
    final view = prefs.playlistsView;

    Future<void> createPlaylist(BuildContext context) async {
      final draft = await showPlaylistDialog(
        context,
        title: 'Nueva lista',
        confirmLabel: 'Crear',
      );
      if (draft == null || !context.mounted) return;
      await favoritesRepo.createPlaylist(
        draft.name,
        description: draft.description.isEmpty ? null : draft.description,
      );
    }

    Widget header(int count) => LibraryTabHeader(
          title: 'Listas',
          count: count,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ViewToggle<PlaylistsView>(
                options: const [
                  (PlaylistsView.grid2, Icons.grid_view_rounded),
                  (PlaylistsView.list, Icons.view_list_rounded),
                ],
                selected: view,
                onSelected: (v) =>
                    ref.read(libraryPrefsProvider.notifier).setPlaylistsView(v),
              ),
              const SizedBox(width: 4),
              SortMenuButton<PlaylistsSort>(
                options: _playlistSortOptions,
                selected: prefs.playlistsSort,
                onSelected: (v) => ref
                    .read(libraryPrefsProvider.notifier)
                    .setPlaylistsSort(v),
              ),
            ],
          ),
        );

    return ref.watch(playlistsProvider).when(
          skipLoadingOnRefresh: true,
          loading: () => const LoadingState(message: 'Cargando listas...'),
          error: (error, _) => ErrorState(
            message: '$error',
            onRetry: () => ref.invalidate(playlistsProvider),
          ),
          data: (playlists) {
            final sorted = sortPlaylists(playlists, prefs.playlistsSort);

            if (view == PlaylistsView.list) {
              final itemCount =
                  3 + (playlists.isEmpty ? 1 : playlists.length);

              Widget createTile() => ListTile(
                    onTap: () => createPlaylist(context),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.add,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    title: const Text(
                      'Crear lista',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      'Empieza una colección nueva',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );

              Widget likedTile() => ListTile(
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
                      'Canciones que me gustan',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      likedCount == 0
                          ? 'Las canciones que te gustan aparecerán aquí'
                          : '$likedCount ${likedCount == 1 ? 'canción' : 'canciones'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );

              return ListView.builder(
                padding: const EdgeInsets.only(bottom: AppDimens.pagePadding),
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  if (index == 0) return header(playlists.length);
                  if (index == 1) return createTile();
                  if (index == 2) return likedTile();

                  if (playlists.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Text(
                        'Tus listas aparecerán aquí.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }
                  final playlist = playlists[index - 3];
                  return PlaylistTile(
                    playlist: playlist,
                    onTap: () => context.push('/playlist/${playlist.id}'),
                  );
                },
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) => CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: header(playlists.length)),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppDimens.pagePadding,
                      0,
                      AppDimens.pagePadding,
                      AppDimens.pagePadding,
                    ),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 16,
                        childAspectRatio: _gridAspect(constraints.maxWidth, 2),
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == 0) {
                            return _CreatePlaylistCard(
                              onTap: () => createPlaylist(context),
                            );
                          }
                          if (index == 1) {
                            return _LikedSongsCard(
                              count: likedCount,
                              onTap: () => context.push('/liked-songs'),
                            );
                          }
                          final playlist = sorted[index - 2];
                          return PlaylistCard(
                            playlist: playlist,
                            onTap: () =>
                                context.push('/playlist/${playlist.id}'),
                          );
                        },
                        childCount: sorted.length + 2,
                      ),
                    ),
                  ),
                ],
              ),
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
    final prefs = ref.watch(libraryPrefsProvider);
    final view = prefs.artistsView;

    if (artists.isEmpty) {
      return const EmptyState(
        icon: Icons.person_outline,
        title: 'Aún no hay artistas',
        message: 'Tus artistas aparecerán aquí cuando añadas música.',
      );
    }

    final sorted = sortArtists(artists, prefs.artistsSort);

    final header = LibraryTabHeader(
      title: 'Artistas',
      count: artists.length,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ViewToggle<ArtistsView>(
            options: const [
              (ArtistsView.grid2, Icons.grid_view_rounded),
              (ArtistsView.list, Icons.view_list_rounded),
            ],
            selected: view,
            onSelected: (v) =>
                ref.read(libraryPrefsProvider.notifier).setArtistsView(v),
          ),
          const SizedBox(width: 4),
          SortMenuButton<ArtistsSort>(
            options: _artistSortOptions,
            selected: prefs.artistsSort,
            onSelected: (v) =>
                ref.read(libraryPrefsProvider.notifier).setArtistsSort(v),
          ),
        ],
      ),
    );

    if (view == ArtistsView.list) {
      return ListView.builder(
        padding: const EdgeInsets.only(bottom: AppDimens.pagePadding),
        itemCount: sorted.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) return header;
          final artist = sorted[index - 1];
          return ArtistTile(
            artist: artist,
            onTap: () => context.push('/artist/${artist.id}'),
          );
        },
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) => CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: header),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.pagePadding,
              0,
              AppDimens.pagePadding,
              AppDimens.pagePadding,
            ),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
                childAspectRatio: _gridAspect(constraints.maxWidth, 2),
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => ArtistCard(
                  artist: sorted[index],
                  onTap: () => context.push('/artist/${sorted[index].id}'),
                ),
                childCount: sorted.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlbumsView extends ConsumerWidget {
  const _AlbumsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albums = ref.watch(albumsProvider);
    final prefs = ref.watch(libraryPrefsProvider);
    final view = prefs.albumsView;

    if (albums.isEmpty) {
      return const EmptyState(
        icon: Icons.album_outlined,
        title: 'Aún no hay álbumes',
        message: 'Tus álbumes aparecerán aquí cuando añadas música.',
      );
    }

    final sorted = sortAlbums(albums, prefs.albumsSort);
    final columns = view == AlbumsView.grid2 ? 2 : 3;

    final header = LibraryTabHeader(
      title: 'Álbumes',
      count: albums.length,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ViewToggle<AlbumsView>(
            options: const [
              (AlbumsView.grid2, Icons.grid_view_rounded),
              (AlbumsView.grid3, Icons.dashboard_outlined),
            ],
            selected: view,
            onSelected: (v) =>
                ref.read(libraryPrefsProvider.notifier).setAlbumsView(v),
          ),
          const SizedBox(width: 4),
          SortMenuButton<AlbumsSort>(
            options: _albumSortOptions,
            selected: prefs.albumsSort,
            onSelected: (v) =>
                ref.read(libraryPrefsProvider.notifier).setAlbumsSort(v),
          ),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) => CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: header),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppDimens.pagePadding,
              0,
              AppDimens.pagePadding,
              AppDimens.pagePadding,
            ),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
                childAspectRatio: _gridAspect(constraints.maxWidth, columns),
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => AlbumCard(
                  album: sorted[index],
                  onTap: () => context.push('/album/${sorted[index].id}'),
                ),
                childCount: sorted.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SongsView extends ConsumerWidget {
  const _SongsView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final library = ref.watch(musicLibraryProvider);
    final prefs = ref.watch(libraryPrefsProvider);
    final songs = library.value ?? const [];
    if (songs.isEmpty) {
      return const EmptyState(
        icon: Icons.music_note,
        title: 'Aún no hay canciones',
        message: 'Tus canciones aparecerán aquí cuando añadas música.',
      );
    }

    final view = prefs.songsView;
    final sorted = sortSongs(songs, prefs.songsSort);

    final header = LibraryTabHeader(
      title: 'Canciones',
      count: songs.length,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ViewToggle<SongsView>(
            options: const [
              (SongsView.list, Icons.view_list_rounded),
              (SongsView.compact, Icons.view_agenda_outlined),
            ],
            selected: view,
            onSelected: (v) =>
                ref.read(libraryPrefsProvider.notifier).setSongsView(v),
          ),
          const SizedBox(width: 4),
          SortMenuButton<SongsSort>(
            options: _songSortOptions,
            selected: prefs.songsSort,
            onSelected: (v) =>
                ref.read(libraryPrefsProvider.notifier).setSongsSort(v),
          ),
        ],
      ),
    );

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: AppDimens.pagePadding),
      itemCount: sorted.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) return header;
        final song = sorted[index - 1];
        return SongListTile(
          song: song,
          compact: view == SongsView.compact,
          queue: sorted,
          onTap: () => ref.read(playerControllerProvider.notifier)
              .playQueue(sorted, startIndex: index - 1),
        );
      },
    );
  }
}

class _CreatePlaylistCard extends StatelessWidget {
  const _CreatePlaylistCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(10),
            ),
            child: AspectRatio(
              aspectRatio: 1,
              child: Icon(
                Icons.add,
                color: theme.colorScheme.onSurfaceVariant,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crear lista',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Empieza una colección nueva',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _LikedSongsCard extends StatelessWidget {
  const _LikedSongsCard({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
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
              borderRadius: BorderRadius.circular(10),
            ),
            child: const AspectRatio(
              aspectRatio: 1,
              child: Icon(Icons.favorite, color: Colors.white, size: 40),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Canciones que me gustan',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            count == 0 ? 'Canciones que te gustan' : '$count canciones',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
