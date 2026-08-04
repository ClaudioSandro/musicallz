/// Contract for the favorites persistence layer.
abstract class FavoritesRepository {
  Future<void> addFavorite(String songId);

  Future<void> removeFavorite(String songId);

  Future<bool> isFavoriteSong(String songId);

  /// Favorite song ids, most recently added first.
  Future<List<String>> getAllFavoriteSongIds();

  Future<void> toggle(String songId);

  /// Emits whenever any favorite is written, so reactive providers can
  /// re-read the collection.
  Stream<void> watchChanges();
}