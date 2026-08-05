import 'package:isar/isar.dart';

part 'session_snapshot.g.dart';

/// Persists the playback session so it can be restored on the next boot.
///
/// A single row (id = 1) is used. [queue] stores each song as a JSON string
/// (see [SongJson] serialization helpers in the session store) so the player
/// can restore the queue without re-reading the whole library.
@collection
class SessionSnapshot {
  Id id = Isar.autoIncrement;

  List<String> queue = <String>[];

  late int currentIndex;

  late int positionMs;

  late bool shuffleEnabled;

  /// One of `off`, `all`, `one` (see [RepeatMode]).
  late String repeatMode;

  late DateTime updatedAt;
}
