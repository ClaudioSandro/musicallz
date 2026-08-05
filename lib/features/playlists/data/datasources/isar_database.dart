import 'dart:io';

import 'package:isar/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../library/data/models/cached_song.dart';
import '../../../library/data/models/session_snapshot.dart';
import '../models/favorite_song.dart';
import '../models/playlist.dart';

/// Opens and caches the single Isar instance for the whole app.
class IsarDatabase {
  IsarDatabase._();

  static const String _dbName = 'musicallz';

  static Isar? _instance;

  static Future<Isar> getInstance() async {
    if (_instance != null) return _instance!;
    final dir = await getApplicationDocumentsDirectory();
    try {
      _instance = await _open(dir.path);
    } on IsarError {
      // Schema changed between releases (Isar has no automatic migrations).
      // Remove the store files so the next open rebuilds from scratch.
      await _removeStoreFiles(dir.path);
      _instance = await _open(dir.path);
    }
    return _instance!;
  }

  static Future<Isar> _open(String dirPath) {
    return Isar.open(
      [
        PlaylistSchema,
        FavoriteSongSchema,
        CachedSongSchema,
        SessionSnapshotSchema,
      ],
      directory: dirPath,
      name: _dbName,
    );
  }

  static Future<void> _removeStoreFiles(String dirPath) async {
    for (final name in ['$_dbName.isar', '$_dbName.lock']) {
      try {
        final file = File(p.join(dirPath, name));
        if (await file.exists()) {
          await file.delete();
        }
      } on FileSystemException {
        // Best effort cleanup; the retry open will surface real failures.
      }
    }
  }

  static Future<void> close() async {
    await _instance?.close();
    _instance = null;
  }
}
