import 'dart:typed_data';

import 'song.dart';

class Album {
  const Album({
    required this.id,
    required this.title,
    required this.artist,
    required this.songCount,
    required this.songs,
    this.year,
    this.coverArt,
  });

  final String id;
  final String title;
  final String artist;
  final int songCount;
  final List<Song> songs;
  final int? year;
  final Uint8List? coverArt;
}