import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
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
                    'Search',
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

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              autofocus: false,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Qué quieres escuchar?',
                hintStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                isDense: true,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                controller.clear();
                onChanged('');
              },
            ),
        ],
      ),
    );
  }
}

class _BrowseGrid extends StatelessWidget {
  const _BrowseGrid();

  @override
  Widget build(BuildContext context) {
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
          children: const [
            _GenreCard(label: 'Pop', color: Color(0xFFE13300)),
            _GenreCard(label: 'Rock', color: Color(0xFF8D67AB)),
            _GenreCard(label: 'Lofi', color: Color(0xFF148A08)),
            _GenreCard(label: 'Electrónica', color: Color(0xFF1E3264)),
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

    return ListView(
      padding: const EdgeInsets.only(bottom: AppDimens.pagePadding),
      children: [
        if (results.songs.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppDimens.pagePadding),
            child: SectionHeader(title: 'Canciones'),
          ),
          gap8,
          ...results.songs.map(
            (song) => SongListTile(
              song: song,
              onTap: () => ref.read(playerControllerProvider.notifier)
                  .playQueue(results.songs,
                      startIndex: results.songs.indexOf(song)),
            ),
          ),
        ],
        if (results.artists.isNotEmpty) ...[
          gap24,
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppDimens.pagePadding),
            child: SectionHeader(title: 'Artistas'),
          ),
          gap8,
          ...results.artists.map(
            (artist) => ArtistTile(
              artist: artist,
              onTap: () => context.push('/artist/${artist.id}'),
            ),
          ),
        ],
        if (results.albums.isNotEmpty) ...[
          gap24,
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppDimens.pagePadding),
            child: SectionHeader(title: 'Álbumes'),
          ),
          gap8,
          ...results.albums.map(
            (album) => AlbumTile(
              album: album,
              onTap: () => context.push('/album/${album.id}'),
            ),
          ),
        ],
      ],
    );
  }
}

class _GenreCard extends StatelessWidget {
  const _GenreCard({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.topLeft,
      child: Text(
        label,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}