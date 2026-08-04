import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/format_duration.dart';
import '../../features/library/domain/entities/song.dart';
import '../../features/library/presentation/widgets/cover_art.dart';
import '../../features/player/presentation/providers/player_providers.dart';
import 'equalizer_bars.dart';
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
  });

  final Song song;
  final VoidCallback? onTap;
  final List<Song>? queue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isCurrent = ref
            .watch(currentSongProvider)
            ?.id ==
        song.id;

    final accent = AppColors.accent;

    final titleStyle = theme.textTheme.bodyLarge?.copyWith(
      fontWeight: FontWeight.w600,
      color: isCurrent ? accent : null,
    );
    final artistStyle = theme.textTheme.bodySmall?.copyWith(
      color: isCurrent ? accent : theme.colorScheme.onSurfaceVariant,
    );

    return ListTile(
      onTap: onTap,
      onLongPress: () => openSongContextMenu(context, ref, song, queue: queue),
      leading: CoverArt(bytes: song.albumArt, size: 48, radius: 8),
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
              tooltip: 'More options',
            ),
          ],
        ),
      ),
      minLeadingWidth: 0,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }
}