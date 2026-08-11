import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/format_duration.dart';
import '../../features/library/domain/entities/song.dart';
import '../../features/library/presentation/widgets/cover_art.dart';
import '../../features/player/presentation/providers/player_providers.dart';
import 'equalizer_bars.dart';
import 'favorite_button.dart';
import 'song_context_menu.dart';

/// A single song row used across list screens.
///
/// The title is tinted with the accent color (and an animated equalizer is
/// shown) while the song is the one currently playing, and the trailing ⋮
/// button opens a contextual bottom sheet.
class SongListTile extends ConsumerWidget {
  const SongListTile({
    super.key,
    required this.song,
    this.onTap,
    this.queue,
    this.compact = false,
  });

  final Song song;
  final VoidCallback? onTap;
  final List<Song>? queue;

  /// When true, renders a denser row (smaller art, single-line subtitle)
  /// for the Songs "compact" view.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isCurrent = ref
            .watch(currentSongProvider)
            ?.id ==
        song.id;

    final accent = theme.colorScheme.primary;

    final titleStyle = theme.textTheme.bodyLarge?.copyWith(
      fontWeight: FontWeight.w600,
      color: isCurrent ? accent : null,
    );
    final artistStyle = theme.textTheme.bodySmall?.copyWith(
      color: isCurrent ? accent : theme.colorScheme.onSurfaceVariant,
    );

    if (compact) {
      return ListTile(
        onTap: onTap,
        onLongPress: () =>
            openSongContextMenu(context, ref, song, queue: queue),
        leading: CoverArt(
          bytes: song.albumArt,
          filePath: song.albumArtPath,
          size: 40,
          radius: 6,
        ),
        title: Text(
          song.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: isCurrent ? accent : null,
          ),
        ),
        subtitle: Text(
          '${song.artist} · ${formatDuration(song.duration)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: isCurrent ? accent : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: IconButton(
          onPressed: () => openSongContextMenu(
            context,
            ref,
            song,
            queue: queue,
          ),
          icon: const Icon(Icons.more_horiz, size: 18),
          visualDensity: VisualDensity.compact,
          color: theme.colorScheme.onSurfaceVariant,
          tooltip: 'Más opciones',
        ),
        minLeadingWidth: 0,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        dense: true,
      );
    }

    return ListTile(
      onTap: onTap,
      onLongPress: () => openSongContextMenu(context, ref, song, queue: queue),
      leading: CoverArt(
        bytes: song.albumArt,
        filePath: song.albumArtPath,
        size: 48,
        radius: 8,
      ),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: titleStyle,
      ),
      subtitle: Text(
        song.artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: artistStyle,
      ),
      trailing: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCurrent) ...[
              EqualizerBars(playing: ref.watch(isPlayingProvider), size: 14),
              const SizedBox(width: 8),
            ],
            Text(
              formatDuration(song.duration),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 4),
            FavoriteButton(songId: song.id, size: 20),
            const SizedBox(width: 2),
            IconButton(
              onPressed: () => openSongContextMenu(
                context,
                ref,
                song,
                queue: queue,
              ),
              icon: const Icon(Icons.more_horiz, size: 20),
              visualDensity: VisualDensity.compact,
              color: theme.colorScheme.onSurfaceVariant,
tooltip: 'Más opciones',
            ),
          ],
        ),
      ),
      minLeadingWidth: 0,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }
}