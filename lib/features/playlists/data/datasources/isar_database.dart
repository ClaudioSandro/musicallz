import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/favorite_song.dart';
import '../models/playlist.dart';

/// Opens and caches the single Isar instance for the whole app.
class IsarDatabase {
  IsarDatabase._();

  static Isar? _instance;

  static Future<Isar> getInstance() async {
    if (_instance != null) return _instance!;
    final dir = await getApplicationDocumentsDirectory();
    _instance = await Isar.open(
      [PlaylistSchema, FavoriteSongSchema],
      directory: dir.path,
      name: 'musicallz',
    );
    return _instance!;
  }

  static Future<void> close() async {
    await _instance?.close();
    _instance = null;
  }
}