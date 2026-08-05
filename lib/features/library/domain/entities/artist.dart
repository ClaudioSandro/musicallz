import 'dart:typed_data';

import 'song.dart';

class Artist {
  const Artist({
    required this.id,
    required this.name,
    required this.songCount,
    required this.albumCount,
    required this.songs,
    this.playCount = 0,
    this.coverArt,
    this.coverArtPath,
  });

  final String id;
  final String name;
  final int songCount;
  final int albumCount;
  final List<Song> songs;

  /// Total play count across the artist's songs. Powers "Top Artists".
  final int playCount;

  final Uint8List? coverArt;
  final String? coverArtPath;
}
