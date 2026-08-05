/// Aggregated counters from the last library scan, shown in Settings.
class LibraryScanMetrics {
  const LibraryScanMetrics({
    required this.filesProcessed,
    required this.reusedFromCache,
    required this.newFiles,
    required this.deletedFiles,
    required this.scannedAt,
  });

  /// Total MP3 files found on disk.
  final int filesProcessed;

  /// Files whose path + size + mtime matched the cache (no re-extraction).
  final int reusedFromCache;

  /// Files that were new or modified and got re-extracted.
  final int newFiles;

  /// Cached entries whose files no longer exist on disk.
  final int deletedFiles;

  final DateTime scannedAt;
}
