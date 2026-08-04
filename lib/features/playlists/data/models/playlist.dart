import 'package:isar/isar.dart';

part 'playlist.g.dart';

/// A user-created playlist.
///
/// It only stores references to local songs via [songIds]; the actual [Song]
/// data always comes from the local media scan. Playlist songs are stored in
/// display order, so reordering only mutates this list before persisting.
@collection
class Playlist {
  Id id = Isar.autoIncrement;

  late String name;

  String? description;

  late DateTime createdAt;

  late DateTime updatedAt;

  String? coverPath;

  List<String> songIds = <String>[];
}