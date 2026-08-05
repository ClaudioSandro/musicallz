import 'dart:convert';

import 'package:isar/isar.dart';

import '../../library/data/models/session_snapshot.dart';
import '../../library/domain/entities/song.dart';
import '../domain/models/player_state.dart';

/// Serializable snapshot of the playback session.
class SessionSnapshotData {
  const SessionSnapshotData({
    required this.queue,
    required this.currentIndex,
    required this.position,
    required this.shuffleEnabled,
    required this.repeatMode,
  });

  final List<Song> queue;
  final int currentIndex;
  final Duration position;
  final bool shuffleEnabled;
  final RepeatMode repeatMode;
}

/// Stores/loads the session. Abstract so tests can inject a no-op store.
abstract class SessionStore {
  Future<SessionSnapshotData?> load();
  Future<void> save(SessionSnapshotData data);
}

/// In-memory store used when Isar is unavailable (e.g. widget tests). The
/// session survives hot restarts of the provider but not app restarts.
class NoopSessionStore implements SessionStore {
  SessionSnapshotData? _last;

  @override
  Future<SessionSnapshotData?> load() async => _last;

  @override
  Future<void> save(SessionSnapshotData data) async {
    _last = data;
  }
}

/// Persists the session in the Isar [SessionSnapshot] collection.
class IsarSessionStore implements SessionStore {
  IsarSessionStore(this._isar);

  final Isar _isar;

  @override
  Future<SessionSnapshotData?> load() async {
    final snap = await _isar.sessionSnapshots.get(1);
    if (snap == null) return null;
    final queue = <Song>[];
    for (final raw in snap.queue) {
      final song = songFromJson(raw);
      if (song != null) queue.add(song);
    }
    return SessionSnapshotData(
      queue: queue,
      currentIndex: snap.currentIndex,
      position: Duration(milliseconds: snap.positionMs),
      shuffleEnabled: snap.shuffleEnabled,
      repeatMode: RepeatMode.values.firstWhere(
        (mode) => mode.name == snap.repeatMode,
        orElse: () => RepeatMode.off,
      ),
    );
  }

  @override
  Future<void> save(SessionSnapshotData data) async {
    await _isar.writeTxn(() async {
      final snap = SessionSnapshot()
        ..id = 1
        ..queue = data.queue.map(songToJson).toList()
        ..currentIndex = data.currentIndex
        ..positionMs = data.position.inMilliseconds
        ..shuffleEnabled = data.shuffleEnabled
        ..repeatMode = data.repeatMode.name
        ..updatedAt = DateTime.now();
      await _isar.sessionSnapshots.put(snap);
    });
  }
}

/// Compact JSON encoding of a [Song] (no album art bytes; only the path, which
/// keeps the snapshot small and lets covers load from the file cache).
String songToJson(Song song) => jsonEncode({
      'id': song.id,
      'title': song.title,
      'artist': song.artist,
      'album': song.album,
      'durationMs': song.duration.inMilliseconds,
      'filePath': song.filePath,
      'trackNumber': song.trackNumber,
      'year': song.year,
      'albumArtPath': song.albumArtPath,
    });

Song? songFromJson(String raw) {
  try {
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return Song(
      id: map['id'] as String,
      title: map['title'] as String,
      artist: map['artist'] as String,
      album: map['album'] as String,
      duration: Duration(milliseconds: (map['durationMs'] as num?)?.toInt() ?? 0),
      filePath: map['filePath'] as String,
      trackNumber: (map['trackNumber'] as num?)?.toInt(),
      year: (map['year'] as num?)?.toInt(),
      albumArtPath: map['albumArtPath'] as String?,
    );
  } on FormatException {
    return null;
  } on TypeError {
    return null;
  }
}
