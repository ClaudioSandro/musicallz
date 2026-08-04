import 'package:flutter/material.dart';

import '../../domain/entities/artist.dart';
import 'cover_art.dart';

class ArtistTile extends StatelessWidget {
  const ArtistTile({super.key, required this.artist, this.onTap});

  final Artist artist;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      leading: CoverArt(
        bytes: artist.coverArt,
        size: 48,
        circular: true,
        icon: Icons.person,
      ),
      title: Text(
        artist.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${artist.songCount} canciones · ${artist.albumCount} álbumes',
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