import 'package:flutter/material.dart';

import '../../domain/entities/album.dart';
import 'cover_art.dart';

class AlbumTile extends StatelessWidget {
  const AlbumTile({super.key, required this.album, this.onTap});

  final Album album;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      leading: CoverArt(bytes: album.coverArt, size: 48),
      title: Text(
        album.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        [
          '${album.artist} · ${album.songCount} canciones',
          if (album.year != null) '${album.year}',
        ].join(' · '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: onTap == null ? null : const Icon(Icons.chevron_right),
    );
  }
}