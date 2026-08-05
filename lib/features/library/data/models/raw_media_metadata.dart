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
    this.genre,
    this.composer,
    this.albumArtist,
    this.discNumber,
  });

  final String? title;
  final String? artist;
  final String? album;
  final Duration duration;
  final int? trackNumber;
  final int? year;
  final Uint8List? albumArt;
  final String? genre;
  final String? composer;
  final String? albumArtist;
  final int? discNumber;
}