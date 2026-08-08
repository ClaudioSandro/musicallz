import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme_extension.dart';
import '../../../../core/utils/format_duration.dart';
import '../../../../core/widgets/player_bottom_shell.dart';
import '../../../../features/library/domain/entities/song.dart';
import '../../../../features/library/presentation/widgets/cover_art.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/equalizer_bars.dart';
import '../providers/player_providers.dart';

/// Spotify-style queue editor: shows the current song and everything queued
/// after it, with tap-to-play, swipe-free removal and drag-to-reorder.
class QueueScreen extends ConsumerWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(currentSongProvider);

    if (current == null) {
      return PlayerBottomShell(
        child: Scaffold(
          appBar: AppBar(),
          body: const EmptyState(
            icon: Icons.queue_music,
            title: 'Nothing playing',
            message: 'Start playing a song and its queue will show up here.',
          ),
        ),
      );
    }

    final upcoming = ref.watch(upcomingQueueProvider);
    final currentIndex = ref.watch(currentIndexProvider);

    return PlayerBottomShell(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Back',
          ),
          title: const Text('Queue', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _SectionLabel('NOW PLAYING'),
              _CurrentRow(song: current, index: currentIndex),
              const Divider(height: 24),
              _SectionLabel(
                upcoming.isEmpty ? 'UP NEXT · EMPTY' : 'UP NEXT · ${upcoming.length}',
              ),
              if (upcoming.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Text(
                    'Nothing next in the queue. Use "Play next" or "Add to queue" '
                    'on any song to build it.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                Expanded(
                  child: ReorderableListView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    buildDefaultDragHandles: false,
                    onReorder: (oldIndex, newIndex) {
                      if (newIndex > oldIndex) newIndex -= 1;
                      final from = currentIndex + 1 + oldIndex;
                      final to = currentIndex + 1 + newIndex;
                      ref.read(playerControllerProvider.notifier)
                          .reorderQueue(from, to);
                    },
                    itemCount: upcoming.length,
                    itemBuilder: (context, i) {
                      final song = upcoming[i];
                      final queueIndex = currentIndex + 1 + i;
                      return _UpcomingRow(
                        key: ValueKey(song.id),
                        song: song,
                        index: i,
                        onTap: () => ref
                            .read(playerControllerProvider.notifier)
                            .skipToIndex(queueIndex),
                        onRemove: () => ref
                            .read(playerControllerProvider.notifier)
                            .removeFromQueue(queueIndex),
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _CurrentRow extends ConsumerWidget {
  const _CurrentRow({required this.song, required this.index});

  final Song song;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final playing = ref.watch(isPlayingProvider);
    return ListTile(
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
        style: TextStyle(
          color: context.brandAccent,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        song.artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (playing) ...[
            EqualizerBars(playing: true, size: 14),
            const SizedBox(width: 8),
          ],
          Text(
            formatDuration(song.duration),
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => HapticFeedback.lightImpact(),
            icon: Icon(
              Icons.more_horiz,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            tooltip: 'Current song',
          ),
        ],
      ),
    );
  }
}

class _UpcomingRow extends StatelessWidget {
  const _UpcomingRow({
    super.key,
    required this.song,
    required this.index,
    required this.onTap,
    required this.onRemove,
  });

  final Song song;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      onTap: onTap,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ReorderableDragStartListener(
            index: index,
            child: Padding(
              padding: const EdgeInsets.only(left: 4, right: 8),
              child: Icon(
                Icons.drag_handle,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          CoverArt(
            bytes: song.albumArt,
            filePath: song.albumArtPath,
            size: 44,
            radius: 8,
          ),
        ],
      ),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        song.artist,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: IconButton(
        onPressed: () {
          HapticFeedback.selectionClick();
          onRemove();
        },
        icon: const Icon(Icons.close, size: 20),
        visualDensity: VisualDensity.compact,
        color: theme.colorScheme.onSurfaceVariant,
        tooltip: 'Remove from queue',
      ),
    );
  }
}
