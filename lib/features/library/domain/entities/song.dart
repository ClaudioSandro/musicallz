import 'dart:typed_data';

class Song {
  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.filePath,
    this.trackNumber,
    this.year,
    this.albumArt,
  });

  final String id;
  final String title;
  final String artist;
  final String album;
  final Duration duration;
  final String filePath;
  final int? trackNumber;
  final int? year;
  final Uint8List? albumArt;
}