import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_gaps.dart';
import '../../../library/domain/entities/song.dart';
import '../../data/models/playlist.dart';
import '../providers/playlist_providers.dart';
import 'playlist_dialog.dart';

const Object _createNew = Object();

/// Opens a bottom sheet listing every playlist plus a "New playlist" action.
/// Picking a playlist adds [song] to it immediately; picking "New playlist"
/// creates it first and then adds the song.
Future<void> showAddToPlaylistSheet(
  BuildContext context,
  WidgetRef ref,
  Song song,
) async {
  final selection = await showModalBottomSheet<Object>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _AddToPlaylistSheet(song: song),
  );

  if (selection == null || !context.mounted) return;

  final repo = ref.read(playlistRepositoryProvider);

  if (identical(selection, _createNew)) {
    final draft = await showPlaylistDialog(
      context,
      title: 'New Playlist',
      confirmLabel: 'Create & Add',
    );
    if (draft == null || !context.mounted) return;
    final playlist = await repo.createPlaylist(
      draft.name,
      description: draft.description.isEmpty ? null : draft.description,
    );
    await repo.addSong(playlist.id, song.id);
    if (!context.mounted) return;
    _notify(context, 'Added to ${playlist.name}');
  } else {
    final chosen = selection as ({int id, String name});
    await repo.addSong(chosen.id, song.id);
    if (!context.mounted) return;
    _notify(context, 'Added to ${chosen.name}');
  }
}

void _notify(BuildContext context, String message) {
  HapticFeedback.selectionClick();
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
}

class _AddToPlaylistSheet extends ConsumerWidget {
  const _AddToPlaylistSheet({required this.song});

  final Song song;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final playlists = ref.watch(playlistsProvider).valueOrNull ?? const [];

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'Add to playlist',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.add, color: theme.colorScheme.onSurfaceVariant),
              title: const Text(
                'New playlist',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              onTap: () => Navigator.of(context).pop(_createNew),
            ),
            if (playlists.isNotEmpty) ...[
              const Divider(height: 1, color: Colors.white12),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 360),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: playlists.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];
                    return _PlaylistRow(
                      playlist: playlist,
                      onTap: () => Navigator.of(context).pop(
                        (id: playlist.id, name: playlist.name),
                      ),
                    );
                  },
                ),
              ),
            ],
            gap12,
          ],
        ),
      ),
    );
  }
}

class _PlaylistRow extends StatelessWidget {
  const _PlaylistRow({required this.playlist, required this.onTap});

  final Playlist playlist;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      leading: _MiniCover(forPlaylist: playlist),
      title: Text(
        playlist.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        '${playlist.songIds.length} songs',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _MiniCover extends ConsumerWidget {
  const _MiniCover({required this.forPlaylist});

  final Playlist forPlaylist;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final map = ref.watch(songByIdProvider);
    final coverBytes = forPlaylist.songIds
        .map((id) => map[id]?.albumArt)
        .where((art) => art != null)
        .firstOrNull;
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox.square(
        dimension: 44,
        child: coverBytes != null
            ? Image.memory(coverBytes, fit: BoxFit.cover)
            : ColoredBox(
                color: themeColor(context),
                child: Icon(
                  Icons.queue_music,
                  size: 20,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
      ),
    );
  }

  Color themeColor(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainerHigh;
}