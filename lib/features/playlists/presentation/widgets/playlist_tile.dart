import 'package:flutter/material.dart';

import '../../data/models/playlist.dart';
import 'playlist_art.dart';

/// A library row for a playlist (name, song count, update date, cover).
class PlaylistTile extends StatelessWidget {
  const PlaylistTile({super.key, required this.playlist, this.onTap});

  final Playlist playlist;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = playlist.songIds.length;
    final updated = playlist.updatedAt;

    final when = 'Updated '
        '${updated.year}-${updated.month.toString().padLeft(2, '0')}-'
        '${updated.day.toString().padLeft(2, '0')}';

    return ListTile(
      onTap: onTap,
      leading: PlaylistArt(playlist: playlist, size: 48, radius: 8),
      title: Text(
        playlist.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '$count ${count == 1 ? 'song' : 'songs'} · $when',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}

/// Formats a [Duration] like "1 h 2 min" or "3 min 4 s" for playlist headers.
String formatPlaylistDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);
  if (hours > 0) return '$hours hr $minutes min';
  if (minutes > 0) return '$minutes min $seconds s';
  return '${seconds}s';
}