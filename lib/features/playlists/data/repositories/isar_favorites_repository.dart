import 'package:isar/isar.dart';

import '../../domain/repositories/favorites_repository.dart';
import '../models/favorite_song.dart';

/// [FavoritesRepository] implemented on top of Isar.
class IsarFavoritesRepository implements FavoritesRepository {
  IsarFavoritesRepository(this._isar);

  final Isar _isar;

  @override
  Future<void> addFavorite(String songId) {
    return _isar.writeTxn(() async {
      if (await isFavoriteSong(songId)) return;
      final favorite = FavoriteSong()
        ..songId = songId
        ..addedAt = DateTime.now();
      await _isar.favoriteSongs.put(favorite);
    });
  }

  @override
  Future<void> removeFavorite(String songId) {
    return _isar.writeTxn(() async {
      final found = await _isar.favoriteSongs
          .where()
          .songIdEqualTo(songId)
          .findFirst();
      if (found != null) {
        await _isar.favoriteSongs.delete(found.id);
      }
    });
  }

  @override
  Future<bool> isFavoriteSong(String songId) async {
    final exists = await _isar.favoriteSongs
        .where()
        .songIdEqualTo(songId)
        .findFirst();
    return exists != null;
  }

  @override
  Future<List<String>> getAllFavoriteSongIds() async {
    final favorites = await _isar.favoriteSongs.where().findAll();
    favorites.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    return favorites.map((f) => f.songId).toList();
  }

  @override
  Future<void> toggle(String songId) async {
    if (await isFavoriteSong(songId)) {
      await removeFavorite(songId);
    } else {
      await addFavorite(songId);
    }
  }

  @override
  Stream<void> watchChanges() => _isar.favoriteSongs.watchLazy();
}