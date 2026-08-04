import 'package:isar/isar.dart';

part 'favorite_song.g.dart';

/// Marks a local song (by id) as favorite.
@collection
class FavoriteSong {
  Id id = Isar.autoIncrement;

  @Index()
  late String songId;

  late DateTime addedAt;
}