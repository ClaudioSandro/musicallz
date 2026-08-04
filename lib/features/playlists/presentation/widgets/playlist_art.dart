import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/playlist.dart';
import '../providers/playlist_providers.dart';

/// Cover art for a playlist. Uses coverPath when set, otherwise the first
/// available song’s album art, defaulting to an icon on a gradient tile.
class PlaylistArt extends ConsumerWidget {
  const PlaylistArt({
    super.key,
    required this.playlist,
    this.size = 48,
    this.radius = 8,
  });

  final Playlist playlist;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coverPath = playlist.coverPath;

    Widget? bytesBased(Uint8List? bytes) {
      if (bytes == null) return null;
      return Image.memory(bytes, fit: BoxFit.cover);
    }

    Widget? fileBased(String path) {
      if (File(path).existsSync()) return Image.file(File(path), fit: BoxFit.cover);
      return null;
    }

    final map = ref.watch(songByIdProvider);
    final firstArt = playlist.songIds
        .map((id) => map[id]?.albumArt)
        .where((art) => art != null)
        .firstOrNull;

    final Widget? child = coverPath != null
        ? fileBased(coverPath) ?? bytesBased(firstArt)
        : bytesBased(firstArt);

    final fallback = DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E7D5B), Color(0xFF1DB954), Color(0xFF0B5C33)],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.queue_music,
          color: Colors.white.withValues(alpha: 0.85),
          size: size * 0.4,
        ),
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox.square(
        dimension: size,
        child: child ?? fallback,
      ),
    );
  }
}