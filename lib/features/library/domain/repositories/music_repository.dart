import '../entities/song.dart';
import '../../data/models/library_scan_metrics.dart';

abstract class MusicRepository {
  /// Songs from the persistent cache (fast boot). Empty until first scan.
  Future<List<Song>> getSongs();

  /// Runs an incremental rescan (new/modified/deleted files only), updates
  /// the persistent cache and returns the up-to-date songs.
  Future<List<Song>> rescan();

  /// Metrics from the last completed scan, if any.
  Future<LibraryScanMetrics?> scanMetrics();

  /// Records a play of [songId], feeding the Top Artists ranking.
  Future<void> recordPlay(String songId);
}
