import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../features/library/domain/entities/song.dart';
import '../../features/library/presentation/widgets/cover_art.dart';
import '../../features/player/presentation/providers/player_providers.dart';

/// Opens a Spotify-style bottom-sheet context menu for [song].
///
/// Actions are wired where existing playback capabilities allow (Play); the
/// remaining advanced actions (Add to playlist, Share, File info) are shown as
/// informational placeholders and are intentionally non-mutating.
Future<void> openSongContextMenu(
  BuildContext context,
  WidgetRef ref,
  Song song, {
  List<Song>? queue,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _SongContextMenu(song: song, queue: queue),
  );
}

class _SongContextMenu extends ConsumerWidget {
  const _SongContextMenu({required this.song, this.queue});

  final Song song;
  final List<Song>? queue;

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final list = queue ?? [song];

    Widget item({
      required IconData icon,
      required String label,
      VoidCallback? onTap,
    }) {
      return ListTile(
        leading: Icon(
          icon,
          color: onTap == null ? theme.colorScheme.onSurfaceVariant : null,
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
      child: Padding(
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
                ref.read(playerControllerProvider.notifier)
                    .playQueue(list, startIndex: list.indexOf(song));
              },
            ),
            item(
              icon: Icons.playlist_add,
              label: 'Add to playlist',
              onTap: () => _placeholder(context, 'Add to playlist'),
            ),
            item(
              icon: Icons.queue_music,
              label: 'Play next',
              onTap: () => _placeholder(context, 'Play next'),
            ),
            item(
              icon: Icons.person_outline,
              label: 'Go to artist',
              onTap: () => _placeholder(context, 'Go to artist'),
            ),
            item(
              icon: Icons.album_outlined,
              label: 'Go to album',
              onTap: () => _placeholder(context, 'Go to album'),
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
                context.push('/now-playing');
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}