import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/utils/app_gaps.dart';
import '../../../features/library/presentation/providers/library_index_provider.dart';
import '../../../features/library/presentation/widgets/album_tile.dart';
import '../../../features/library/presentation/widgets/artist_tile.dart';
import '../../../features/player/presentation/providers/player_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/song_list_tile.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(searchQueryProvider));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    ref.read(searchQueryProvider.notifier).state = value;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = ref.watch(searchQueryProvider);

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
                    'Buscar',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  gap16,
                  _SearchField(
                    controller: _controller,
                    onChanged: _onQueryChanged,
                  ),
                ],
              ),
            ),
            gap16,
            Expanded(
              child: query.trim().isEmpty
                  ? const _BrowseGrid()
                  : _SearchResults(query: query.trim()),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatefulWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _focused ? theme.colorScheme.primary : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: widget.controller,
              onChanged: widget.onChanged,
              autofocus: false,
              textInputAction: TextInputAction.search,
              onTap: () => setState(() => _focused = true),
              onSubmitted: (_) => setState(() => _focused = false),
              onEditingComplete: () => setState(() => _focused = false),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '¿Qué quieres escuchar?',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                isDense: true,
              ),
            ),
          ),
          if (widget.controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                widget.controller.clear();
                widget.onChanged('');
                setState(() => _focused = false);
              },
            ),
        ],
      ),
    );
  }
}

class _BrowseGrid extends ConsumerWidget {
  const _BrowseGrid();

  static const _palette = [
    Color(0xFFE13300),
    Color(0xFF8D67AB),
    Color(0xFF148A08),
    Color(0xFF1E3264),
    Color(0xFFE8115B),
    Color(0xFF008A5B),
    Color(0xFF7358FF),
    Color(0xFF503750),
    Color(0xFFBA5D07),
    Color(0xFFD84000),
    Color(0xFF0D73EC),
    Color(0xFF777777),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final genres =
        ref.watch(libraryIndexProvider)?.genres ?? const <String>[];
    // Genres are hidden until the library has at least three of them.
    if (genres.length < 3) {
      return const SizedBox.shrink();
    }
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.pagePadding),
      children: [
        const SectionHeader(title: 'Explorar géneros'),
        gap16,
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            for (final genre in genres)
              _GenreCard(
                label: genre,
                color: _palette[genre.hashCode.abs() % _palette.length],
                onTap: () => context.push(
                  '/genre/${Uri.encodeComponent(genre)}',
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(searchResultsProvider);

    if (results.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off,
        title: 'Sin resultados',
        message: 'No encontramos canciones, artistas o álbumes para tu búsqueda.',
      );
    }

    final songsLen = results.songs.length;
    final artistsLen = results.artists.length;
    final albumsLen = results.albums.length;

    Widget? section(bool has, String title) => has
        ? Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppDimens.pagePadding),
            child: SectionHeader(title: title),
          )
        : null;

    final songsHeader = section(songsLen > 0, 'Canciones');
    final artistsHeader = section(artistsLen > 0, 'Artistas');
    final albumsHeader = section(albumsLen > 0, 'Álbumes');

    final total = (songsLen > 0 ? 1 + songsLen : 0) +
        (artistsLen > 0 ? 1 + artistsLen : 0) +
        (albumsLen > 0 ? 1 + albumsLen : 0);

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: AppDimens.pagePadding),
      itemCount: total,
      itemBuilder: (context, index) {
        if (songsLen > 0) {
          if (index == 0) return songsHeader!;
          if (index < 1 + songsLen) {
            final song = results.songs[index - 1];
            return SongListTile(
              song: song,
              onTap: () => ref.read(playerControllerProvider.notifier)
                  .playQueue(results.songs, startIndex: index - 1),
            );
          }
          index -= 1 + songsLen;
        }
        if (artistsLen > 0) {
          if (index == 0) return artistsHeader!;
          if (index < 1 + artistsLen) {
            final artist = results.artists[index - 1];
            return ArtistTile(
              artist: artist,
              onTap: () => context.push('/artist/${artist.id}'),
            );
          }
          index -= 1 + artistsLen;
        }
        if (albumsLen > 0) {
          if (index == 0) return albumsHeader!;
          final album = results.albums[index - 1];
          return AlbumTile(
            album: album,
            onTap: () => context.push('/album/${album.id}'),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _GenreCard extends StatelessWidget {
  const _GenreCard({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          alignment: Alignment.topLeft,
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}