import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local_music_datasource.dart';
import '../../data/repositories/cached_library_repository.dart';
import '../../domain/repositories/music_repository.dart';
import '../../../playlists/presentation/providers/isar_provider.dart';

final musicRepositoryProvider = Provider<MusicRepository>((ref) {
  return CachedLibraryRepository(
    LocalMusicDatasource(),
    ref.watch(isarProvider),
  );
});
