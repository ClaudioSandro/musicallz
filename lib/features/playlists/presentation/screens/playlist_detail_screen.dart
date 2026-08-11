import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/format_duration.dart';
import '../../../../core/utils/app_gaps.dart';
import '../../../../core/widgets/player_bottom_shell.dart';
import '../../../library/domain/entities/song.dart';
import '../../../library/presentation/widgets/cover_art.dart';
import '../../../player/presentation/providers/player_providers.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/favorite_button.dart';
import '../../../../shared/widgets/song_context_menu.dart';
import '../../data/models/playlist.dart';
import '../providers/playlist_providers.dart';
import '../widgets/playlist_art.dart';
import '../widgets/playlist_dialog.dart';
import '../widgets/playlist_tile.dart';

class PlaylistDetailScreen extends ConsumerWidget {
  const PlaylistDetailScreen({super.key, required this.playlistId});

  final int playlistId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlist = ref.watch(playlistProvider(playlistId));
    final repo = ref.read(playlistRepositoryProvider);

    if (playlist == null) {
      return PlayerBottomShell(
        child: Scaffold(
          appBar: AppBar(),
          body: const EmptyState(
            icon: Icons.queue_music,
            title: 'Lista no encontrada',
            message: 'Esta lista fue eliminada.',
          ),
        ),
      );
    }

    final songs = ref.watch(songsByIdProvider(playlist.songIds));
    final totalDuration = songs.fold<Duration>(
      Duration.zero,
      (acc, song) => acc + song.duration,
    );

    return PlayerBottomShell(
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PlaylistHeader(
                playlist: playlist,
                count: songs.length,
                totalDuration: totalDuration,
                onPlay: () => ref
                    .read(playerControllerProvider.notifier)
                    .playQueue(songs),
                onShuffle: () async {
                  final ctrl =
                      ref.read(playerControllerProvider.notifier);
                  await ctrl.applyAudioShuffle(true);
                  await ctrl.playQueue(songs);
                },
                onEdit: () async {
                  final draft = await showPlaylistDialog(
                    context,
                    title: 'Editar lista',
                    confirmLabel: 'Guardar',
                    initialName: playlist.name,
                    initialDescription: playlist.description ?? '',
                  );
                  if (draft == null || !context.mounted) return;
                  await repo.renamePlaylist(playlist.id, draft.name);
                  await repo.updateDescription(
                    playlist.id,
                    draft.description.isEmpty
                        ? null
                        : draft.description,
                  );
                },
                onDelete: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerLow,
                      title: const Text('¿Eliminar lista?'),
                      content: Text(
                        '"${playlist.name}" y su orden de reproducción serán '
                        'eliminados. Tus canciones no se verán afectadas.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancelar'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                          ),
                          child: const Text('Eliminar'),
                        ),
                      ],
                    ),
                  );
                  if (confirmed != true || !context.mounted) return;
                  await repo.deletePlaylist(playlist.id);
                  if (context.mounted) Navigator.of(context).pop();
                },
              ),
              const Divider(height: 1),
              Expanded(
                child: songs.isEmpty
                    ? const EmptyState(
                        icon: Icons.queue_music,
                        title: 'Aún no hay canciones',
                        message: 'Usa "Añadir a la lista" en cualquier canción '
                            'para llenar esta lista.',
                      )
                    : ReorderableListView.builder(
                        padding:
                            const EdgeInsets.only(bottom: 24),
                        buildDefaultDragHandles: false,
                        onReorder: (oldIndex, newIndex) {
                          if (newIndex > oldIndex) newIndex -= 1;
                          repo.moveSong(playlist.id, oldIndex, newIndex);
                        },
                        itemCount: songs.length,
                        itemBuilder: (context, index) {
                          final song = songs[index];
                          return _PlaylistSongTile(
                            key: ValueKey(song.id),
                            song: song,
                            index: index,
                            playlist: playlist,
                            queue: songs,
                            onTap: () => ref
                                .read(playerControllerProvider.notifier)
                                .playQueue(songs, startIndex: index),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaylistHeader extends StatelessWidget {
  const _PlaylistHeader({
    required this.playlist,
    required this.count,
    required this.totalDuration,
    required this.onPlay,
    required this.onShuffle,
    required this.onEdit,
    required this.onDelete,
  });

  final Playlist playlist;
  final int count;
  final Duration totalDuration;
  final VoidCallback onPlay;
  final VoidCallback onShuffle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Atrás',
              ),
              const Spacer(),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_horiz),
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Editar detalles')),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Eliminar lista',
                        style: TextStyle(color: Colors.redAccent)),
                  ),
                ],
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              PlaylistArt(playlist: playlist, size: 160, radius: 16),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      playlist.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (playlist.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        playlist.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '$count ${count == 1 ? 'canción' : 'canciones'} · '
                      '${formatPlaylistDuration(totalDuration)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton.filled(
                onPressed: onPlay,
                icon: const Icon(Icons.play_arrow, size: 30),
                tooltip: 'Reproducir lista',
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
              ),
              gap12,
              IconButton(
                onPressed: onShuffle,
                icon: Icon(
                  Icons.shuffle,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                tooltip: 'Aleatorio',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlaylistSongTile extends ConsumerWidget {
  const _PlaylistSongTile({
    super.key,
    required this.song,
    required this.index,
    required this.playlist,
    required this.queue,
    required this.onTap,
  });

  final Song song;
  final int index;
  final Playlist playlist;
  final List<Song> queue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ReorderableDragStartListener(
            index: index,
            child: Padding(
              padding: const EdgeInsets.only(right: 4, left: 8),
              child: Icon(
                Icons.drag_handle,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          CoverArt(bytes: song.albumArt, filePath: song.albumArtPath, size: 48, radius: 8),
        ],
      ),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        formatDuration(song.duration),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FavoriteButton(songId: song.id, size: 20),
          const SizedBox(width: 2),
          IconButton(
            onPressed: () => openSongContextMenu(
              context,
              ref,
              song,
              queue: queue,
              playlist: playlist,
            ),
            icon: const Icon(Icons.more_horiz, size: 20),
            visualDensity: VisualDensity.compact,
            color: theme.colorScheme.onSurfaceVariant,
            tooltip: 'Más opciones',
          ),
        ],
      ),
      contentPadding: const EdgeInsets.only(right: 8, left: 4),
    );
  }
}