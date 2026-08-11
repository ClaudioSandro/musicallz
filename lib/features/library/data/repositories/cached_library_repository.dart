import 'dart:io';
import 'dart:typed_data';

import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/song.dart';
import '../../domain/exceptions/music_library_exceptions.dart';
import '../../domain/repositories/music_repository.dart';
import '../datasources/local_music_datasource.dart';
import '../models/cached_song.dart';
import '../models/library_scan_metrics.dart';
import '../models/raw_media_metadata.dart';

/// Cache-first [MusicRepository].
///
/// Songs are persisted in Isar ([CachedSong]) so boot renders instantly from
/// cache. [rescan] walks the folder once and, for each file, compares
/// path + size + mtime against the cache: unchanged files are reused as-is,
/// only new/modified files go through the slow metadata extraction, and
/// cached entries whose file disappeared are removed. Album art is extracted
/// once and saved as a file in the app support directory (the DB only keeps
/// the path).
class CachedLibraryRepository implements MusicRepository {
  CachedLibraryRepository(this._datasource, this._isar);

  static const String unknownTitle = 'Título desconocido';
  static const String unknownArtist = 'Artista desconocido';
  static const String unknownAlbum = 'Álbum desconocido';

  static const String _coverFolderName = 'covers';

  final LocalMusicDatasource _datasource;
  final Isar _isar;

  LibraryScanMetrics? _lastMetrics;

  @override
  Future<List<Song>> getSongs() async {
    final cached = await _isar.cachedSongs.where().findAll();
    cached.sort((a, b) {
      final byArtist = a.artist.toLowerCase().compareTo(b.artist.toLowerCase());
      if (byArtist != 0) return byArtist;
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });
    return cached.map(_toSong).toList();
  }

  @override
  Future<List<Song>> rescan() async {
    final root = await _datasource.resolveLibraryRoot();
    if (root == null || !await root.exists()) {
      return getSongs();
    }

    final List<File> files;
    try {
      files = await _datasource.findMp3Files(root);
    } on FileSystemException {
      throw const MusicLibraryScanException(
        'No se pudo leer la carpeta Music. '
        'Revisa el permiso de almacenamiento.',
      );
    }

    final coverDir = await _coverDirectory();
    final cached = await _isar.cachedSongs.where().findAll();
    final cachedByPath = {for (final c in cached) c.filePath: c};

    final now = DateTime.now();
    final results = <CachedSong>[];
    var reused = 0;
    var created = 0;

    for (final file in files) {
      final stat = await file.stat();
      final existing = cachedByPath[file.path];
      if (existing != null &&
          existing.fileSize == stat.size &&
          existing.lastModifiedMs == stat.modified.millisecondsSinceEpoch) {
        results.add(existing);
        reused++;
        continue;
      }

      final metadata = await _datasource.readMetadata(file);
      final coverPath =
          await _persistCover(coverDir, file, metadata?.albumArt);
      final song = CachedSong()
        ..filePath = file.path
        ..title = _displayTitle(file, metadata)
        ..artist = _nonEmpty(metadata?.artist) ?? unknownArtist
        ..album = _nonEmpty(metadata?.album) ?? unknownAlbum
        ..durationMs = metadata?.duration.inMilliseconds ?? 0
        ..trackNumber = metadata?.trackNumber
        ..year = metadata?.year
        ..coverPath = coverPath
        ..genre = _nonEmpty(metadata?.genre)
        ..composer = _nonEmpty(metadata?.composer)
        ..albumArtist = _nonEmpty(metadata?.albumArtist)
        ..discNumber = metadata?.discNumber
        ..fileSize = stat.size
        ..lastModifiedMs = stat.modified.millisecondsSinceEpoch
        ..playCount = existing?.playCount ?? 0
        ..lastPlayedAt = existing?.lastPlayedAt
        ..addedAt = existing?.addedAt ?? now;
      results.add(song);
      created++;
    }

    final currentPaths = files.map((f) => f.path).toSet();
    final deleted = cached
        .where((c) => !currentPaths.contains(c.filePath))
        .toList();
    for (final c in deleted) {
      if (c.coverPath != null) {
        try {
          await File(c.coverPath!).delete();
        } on FileSystemException {
          // Best effort cleanup.
        }
      }
    }

    await _isar.writeTxn(() async {
      await _isar.cachedSongs.putAll(results);
      if (deleted.isNotEmpty) {
        await _isar.cachedSongs
            .deleteAll(deleted.map((c) => c.id).toList());
      }
    });

    _lastMetrics = LibraryScanMetrics(
      filesProcessed: files.length,
      reusedFromCache: reused,
      newFiles: created,
      deletedFiles: deleted.length,
      scannedAt: now,
    );

    return getSongs();
  }

  @override
  Future<LibraryScanMetrics?> scanMetrics() async => _lastMetrics;

  @override
  Future<void> recordPlay(String songId) async {
    final song =
        await _isar.cachedSongs.where().filePathEqualTo(songId).findFirst();
    if (song == null) return;
    song.playCount += 1;
    song.lastPlayedAt = DateTime.now();
    await _isar.writeTxn(() => _isar.cachedSongs.put(song));
  }

  Future<Directory> _coverDirectory() async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory(p.join(base.path, _coverFolderName));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Writes [bytes] to disk under [dir] with a deterministic name derived
  /// from [file]. Returns the file path, or `null` when there is no art.
  Future<String?> _persistCover(
    Directory dir,
    File file,
    Uint8List? bytes,
  ) async {
    if (bytes == null || bytes.isEmpty) return null;
    final name =
        '${p.basenameWithoutExtension(file.path)}-'
        '${file.path.hashCode.toRadixString(16)}.jpg';
    final target = File(p.join(dir.path, name));
    try {
      await target.writeAsBytes(bytes, flush: true);
      return target.path;
    } on FileSystemException {
      return null;
    }
  }

  Song _toSong(CachedSong c) => Song(
        id: c.filePath,
        title: c.title,
        artist: c.artist,
        album: c.album,
        duration: Duration(milliseconds: c.durationMs),
        filePath: c.filePath,
        trackNumber: c.trackNumber,
        year: c.year,
        albumArtPath: c.coverPath,
        addedAt: c.addedAt,
        modifiedAt: DateTime.fromMillisecondsSinceEpoch(c.lastModifiedMs),
        playCount: c.playCount,
        albumArtist: c.albumArtist,
        genre: c.genre,
        composer: c.composer,
        discNumber: c.discNumber,
      );

  String _displayTitle(File file, RawMediaMetadata? metadata) {
    final fileName = p.basenameWithoutExtension(file.path).trim();
    final title = _nonEmpty(metadata?.title) ?? fileName;
    return _nonEmpty(title) ?? unknownTitle;
  }

  String? _nonEmpty(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }
}
