import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../features/library/domain/entities/song.dart';
import '../../features/library/presentation/widgets/cover_art.dart';
import '../../features/player/presentation/providers/player_providers.dart';
import '../../features/playlists/data/models/playlist.dart';
import '../../features/playlists/presentation/providers/playlist_providers.dart';
import '../../features/playlists/presentation/widgets/add_to_playlist_sheet.dart';

/// Opens a Spotify-style bottom-sheet context menu for [song].
///
/// Playback uses the current [queue] (defaults to just the song). When
/// [playlist] is provided, an extra "Remove from playlist" action is shown.
///
/// Actions that keep running after the sheet closes (like "Add to playlist")
/// use [callerContext]/[callerRef] from the opening screen instead of the
/// sheet's own context, which is disposed as soon as the sheet pops.
Future<void> openSongContextMenu(
  BuildContext callerContext,
  WidgetRef callerRef,
  Song song, {
  List<Song>? queue,
  Playlist? playlist,
}) {
  return showModalBottomSheet<void>(
    context: callerContext,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) => _SongContextMenu(
      song: song,
      queue: queue,
      playlist: playlist,
      callerContext: callerContext,
      callerRef: callerRef,
    ),
  );
}

class _SongContextMenu extends ConsumerWidget {
  const _SongContextMenu({
    required this.song,
    this.queue,
    this.playlist,
    required this.callerContext,
    required this.callerRef,
  });

  final Song song;
  final List<Song>? queue;
  final Playlist? playlist;
  final BuildContext callerContext;
  final WidgetRef callerRef;

  void _placeholder(BuildContext context, String message) {
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

  void _notify(BuildContext context, String message) {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final list = queue ?? [song];
    final isFavorite = ref.watch(isFavoriteProvider(song.id));
    final favoritesRepo = ref.read(favoritesRepositoryProvider);
    final playlistRepo = ref.read(playlistRepositoryProvider);
    final player = ref.read(playerControllerProvider.notifier);
    final currentPlaylist = playlist;

    Widget item({
      required IconData icon,
      required String label,
      VoidCallback? onTap,
      Color? color,
    }) {
      return ListTile(
        leading: Icon(
          icon,
          color: color ?? theme.colorScheme.onSurfaceVariant,
        ),
        title: Text(
          label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        onTap: onTap ??
            () => _placeholder(
                context, '$label is not available in this version yet.'),
      );
    }

    return SafeArea(
      top: false,
      // The menu can outgrow small screens, so the whole list scrolls instead
      // of overflowing ("BOTTOM OVERFLOWED BY N PIXELS").
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CoverArt(bytes: song.albumArt, size: 56, radius: 8),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        song.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            item(
              icon: Icons.play_arrow_rounded,
              label: 'Play',
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.of(context).pop();
                player.playQueue(list, startIndex: list.indexOf(song));
              },
            ),
            item(
              icon: Icons.playlist_add,
              label: 'Add to playlist',
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.of(context).pop();
                if (!callerContext.mounted) return;
                showAddToPlaylistSheet(callerContext, callerRef, song);
              },
            ),
            item(
              icon: Icons.queue_music,
              label: 'Play next',
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.of(context).pop();
                if (!callerContext.mounted) return;
                player.playNext(song);
                _notify(callerContext, 'Playing next');
              },
            ),
            item(
              icon: Icons.add_to_queue,
              label: 'Add to queue',
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.of(context).pop();
                if (!callerContext.mounted) return;
                player.addToQueue(song);
                _notify(callerContext, 'Added to queue');
              },
            ),
            item(
              icon: isFavorite ? Icons.favorite : Icons.favorite_border,
              label: isFavorite
                  ? 'Remove from Liked Songs'
                  : 'Add to Liked Songs',
              color: isFavorite ? AppColors.accent : null,
              onTap: () {
                HapticFeedback.selectionClick();
                favoritesRepo.toggle(song.id);
                Navigator.of(context).pop();
              },
            ),
            if (currentPlaylist != null)
              item(
                icon: Icons.playlist_remove,
                label: 'Remove from ${currentPlaylist.name}',
                onTap: () {
                  HapticFeedback.selectionClick();
                  playlistRepo.removeSong(currentPlaylist.id, song.id);
                  Navigator.of(context).pop();
                },
              ),
            item(
              icon: Icons.person_outline,
              label: 'Go to artist',
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.of(context).pop();
                if (!callerContext.mounted) return;
                callerContext.push(
                  '/artist/${song.artist.trim().toLowerCase()}',
                );
              },
            ),
            item(
              icon: Icons.album_outlined,
              label: 'Go to album',
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.of(context).pop();
                if (!callerContext.mounted) return;
                callerContext.push(
                  '/album/${song.artist.trim().toLowerCase()}'
                  '::${song.album.trim().toLowerCase()}',
                );
              },
            ),
            item(
              icon: Icons.share_outlined,
              label: 'Share',
              onTap: () => _placeholder(context, 'Share'),
            ),
            item(
              icon: Icons.info_outline,
              label: 'File info',
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.of(context).pop();
                if (!callerContext.mounted) return;
                callerContext.push('/now-playing');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
