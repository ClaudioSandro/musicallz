import 'package:isar/isar.dart';

part 'cached_song.g.dart';

/// Persistent copy of one local MP3's metadata plus scan bookkeeping.
///
/// The album art bytes are extracted once during the scan and written to a
/// file on disk; [coverPath] points to it so the database never stores large
/// blobs. [addedAt] is the first-seen date (drives "Recently Added") and
/// [playCount]/[lastPlayedAt] power the "Top Artists" ranking.
@collection
class CachedSong {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String filePath;

  late String title;

  late String artist;

  late String album;

  late int durationMs;

  int? trackNumber;

  int? year;

  String? coverPath;

  String? genre;

  String? composer;

  String? albumArtist;

  int? discNumber;

  /// Size in bytes at last scan, used to detect modified files.
  late int fileSize;

  /// File mtime (ms since epoch) at last scan, used to detect modified files.
  late int lastModifiedMs;

  late int playCount;

  late DateTime addedAt;

  DateTime? lastPlayedAt;
}
