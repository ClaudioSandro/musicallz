import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/models/library_scan_metrics.dart';
import '../../domain/entities/song.dart';
import '../../domain/exceptions/music_library_exceptions.dart';
import '../../domain/repositories/music_repository.dart';
import 'library_permission_provider.dart';
import 'music_repository_provider.dart';

class MusicLibraryNotifier extends AsyncNotifier<List<Song>> {
  @override
  Future<List<Song>> build() async {
    final status = await ref.watch(libraryPermissionProvider.future);
    if (!status.isGranted) {
      throw const MusicLibraryPermissionDeniedException();
    }

    final repository = ref.read(musicRepositoryProvider);
    final songs = await repository.getSongs();

    // Cache hit: show it instantly, then refresh in the background so the UI
    // never blocks on a full scan. On first run the cache is empty, so the
    // initial scan runs inline.
    if (songs.isEmpty) {
      final scanned = await repository.rescan();
      ref.invalidate(scanMetricsProvider);
      return scanned;
    }
    unawaited(_refreshQuietly(repository));
    return songs;
  }

  Future<void> _refreshQuietly(MusicRepository repository) async {
    try {
      final updated = await repository.rescan();
      ref.invalidate(scanMetricsProvider);
      state = AsyncValue.data(updated);
    } catch (error, stackTrace) {
      // Keep the cached library visible; report the failure.
      state = AsyncError(error, stackTrace);
    }
  }

  /// Manual "Rescan Library" action. Keeps the current list on screen while
  /// the incremental scan runs and only swaps in the fresh data at the end.
  Future<void> refresh() async {
    final repository = ref.read(musicRepositoryProvider);
    state = await AsyncValue.guard(() async {
      final updated = await repository.rescan();
      ref.invalidate(scanMetricsProvider);
      return updated;
    });
  }
}

final musicLibraryProvider =
    AsyncNotifierProvider<MusicLibraryNotifier, List<Song>>(
  MusicLibraryNotifier.new,
);

/// Metrics of the last scan, invalidated after every rescan so Settings stays
/// in sync.
final scanMetricsProvider = FutureProvider<LibraryScanMetrics?>((ref) {
  return ref.watch(musicRepositoryProvider).scanMetrics();
});
