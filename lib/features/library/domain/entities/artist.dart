import 'dart:typed_data';

import 'song.dart';

class Artist {
  const Artist({
    required this.id,
    required this.name,
    required this.songCount,
    required this.albumCount,
    required this.songs,
    this.coverArt,
  });

  final String id;
  final String name;
  final int songCount;
  final int albumCount;
  final List<Song> songs;
  final Uint8List? coverArt;
}