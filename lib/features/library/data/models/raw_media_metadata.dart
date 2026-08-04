import 'dart:typed_data';

class RawMediaMetadata {
  const RawMediaMetadata({
    this.title,
    this.artist,
    this.album,
    required this.duration,
    this.trackNumber,
    this.year,
    this.albumArt,
  });

  final String? title;
  final String? artist;
  final String? album;
  final Duration duration;
  final int? trackNumber;
  final int? year;
  final Uint8List? albumArt;
}