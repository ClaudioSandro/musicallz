import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/entities/song.dart';
import '../../domain/exceptions/music_library_exceptions.dart';
import 'library_permission_provider.dart';
import 'music_repository_provider.dart';

class MusicLibraryNotifier extends AsyncNotifier<List<Song>> {
  @override
  Future<List<Song>> build() async {
    final status = await ref.watch(libraryPermissionProvider.future);
    if (!status.isGranted) {
      throw const MusicLibraryPermissionDeniedException();
    }

    final repository = ref.watch(musicRepositoryProvider);
    return repository.getSongs();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(build);
  }
}

final musicLibraryProvider =
    AsyncNotifierProvider<MusicLibraryNotifier, List<Song>>(
  MusicLibraryNotifier.new,
);