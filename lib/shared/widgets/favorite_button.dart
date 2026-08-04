import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../features/playlists/presentation/providers/playlist_providers.dart';

/// A Spotify-style heart toggle. Green when the song is a favorite.
class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({super.key, required this.songId, this.size = 22});

  final String songId;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isFavorite = ref.watch(isFavoriteProvider(songId));
    final repo = ref.read(favoritesRepositoryProvider);

    return IconButton(
      onPressed: () {
        HapticFeedback.selectionClick();
        repo.toggle(songId);
      },
      visualDensity: VisualDensity.compact,
      tooltip: isFavorite
          ? 'Remove from Liked Songs'
          : 'Add to Liked Songs',
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: animation,
          child: child,
        ),
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          key: ValueKey('fav-$isFavorite'),
          size: size,
          color: isFavorite
              ? AppColors.accent
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}