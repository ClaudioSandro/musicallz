import 'dart:typed_data';

import '../services/artist_names.dart';

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
    this.albumArtPath,
    this.addedAt,
    this.modifiedAt,
    this.playCount = 0,
    this.albumArtist,
    this.genre,
    this.composer,
    this.discNumber,
  });

  final String id;
  final String title;

  /// Original `artist` tag, kept intact for display (e.g. `"Aimer feat. LiSA"`).
  final String artist;

  final String album;
  final Duration duration;
  final String filePath;
  final int? trackNumber;
  final int? year;
  final Uint8List? albumArt;
  final String? albumArtPath;

  /// First-seen date (drives "Recently Added" fallback).
  final DateTime? addedAt;

  /// File modification date, used by "Recently Added" when present.
  final DateTime? modifiedAt;

  final int playCount;

  /// `TPE2` album artist. When present, the album is attributed to it instead
  /// of the track's primary artist.
  final String? albumArtist;

  final String? genre;
  final String? composer;
  final int? discNumber;

  /// Individual artists that participated in this track (split from [artist]).
  List<String> get artists => ArtistNames.split(artist);

  /// The first listed artist (used to attribute albums when there is no
  /// [albumArtist] tag).
  String get primaryArtist => artists.isEmpty ? artist : artists.first;
}
