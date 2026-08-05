import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/utils/app_gaps.dart';
import '../../../../features/player/presentation/providers/player_providers.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/song_list_tile.dart';
import '../../domain/entities/album.dart';
import '../../domain/entities/artist.dart';
import '../../domain/entities/song.dart';
import '../providers/library_index_provider.dart';

class ArtistDetailScreen extends ConsumerWidget {
  const ArtistDetailScreen({super.key, required this.artistId});

  final String artistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final artist = ref.watch(artistProvider(artistId));
    final songs = ref.watch(artistSongsProvider(artistId));

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

    // Albums that contain any song by this artist (a song may be part of an
    // album attributed to a different album artist).
    final orderedAlbums =
        ref.watch(libraryIndexProvider)?.albumsForArtist(artistId) ??
            const <Album>[];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 380,
            backgroundColor: theme.colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _ArtistHeader(
                artist: artist,
                onPlay: () => ref.read(playerControllerProvider.notifier)
                    .playQueue(songs),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.pagePadding,
                vertical: 16,
              ),
              child: _SongGroups(
                songs: songs,
                albums: orderedAlbums,
                fullQueue: songs,
              ),
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
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.lerp(AppColors.accent, Colors.black, 0.5)!,
                Colors.black.withValues(alpha: 0.3),
              ],
            ),
          ),
        ),
        // SafeArea keeps the header below the status bar (it used to overlap
        // the clock/battery and the back arrow); Align.topCenter centers it.
        SafeArea(
          bottom: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppDimens.pagePadding,
                AppDimens.pagePadding,
                AppDimens.pagePadding,
                40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    artist.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  gap4,
                  Text(
                    'Artista',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  gap8,
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16,
                    children: [
                      _Stat(value: '${artist.songCount}', label: 'canciones'),
                      _Stat(value: '${artist.albumCount}', label: 'álbumes'),
                    ],
                  ),
                  gap16,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filled(
                        onPressed: onPlay,
                        icon: const Icon(Icons.play_arrow, size: 28),
                        tooltip: 'Play artist',
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.black,
                        ),
                      ),
                      gap12,
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.favorite_border,
                            color: Colors.white),
                        tooltip: 'Follow artist',
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

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
      ],
    );
  }
}

class _SongGroups extends ConsumerWidget {
  const _SongGroups({
    required this.songs,
    required this.albums,
    required this.fullQueue,
  });

  final List<Song> songs;
  final List<Album> albums;
  final List<Song> fullQueue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // If there are albums for this artist, group songs under album headers.
    if (albums.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...albums.map((album) {
            final albumSongs = songs
                .where((s) => s.album == album.title)
                .toList();
            if (albumSongs.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: album.title,
                  subtitle: album.year?.toString(),
                ),
                gap8,
                ...albumSongs.map(
                  (song) => SongListTile(
                    song: song,
                    queue: fullQueue,
                    onTap: () => ref
                        .read(playerControllerProvider.notifier)
                        .playQueue(fullQueue,
                            startIndex: fullQueue.indexOf(song)),
                  ),
                ),
                gap24,
              ],
            );
          }),
          const SectionHeader(title: 'Populares'),
          gap8,
          ...songs.map(
            (song) => SongListTile(
              song: song,
              queue: fullQueue,
              onTap: () => ref.read(playerControllerProvider.notifier)
                  .playQueue(fullQueue,
                      startIndex: fullQueue.indexOf(song)),
            ),
          ),
        ],
      );
    }

    // Fallback: plain song list.
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Canciones',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        gap8,
        ...songs.map(
          (song) => SongListTile(
            song: song,
            queue: fullQueue,
            onTap: () => ref.read(playerControllerProvider.notifier)
                .playQueue(fullQueue,
                    startIndex: fullQueue.indexOf(song)),
          ),
        ),
      ],
    );
  }
}