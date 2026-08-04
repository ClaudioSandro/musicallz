import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local_music_datasource.dart';
import '../../data/repositories/local_music_repository.dart';
import '../../domain/repositories/music_repository.dart';

final musicRepositoryProvider = Provider<MusicRepository>((ref) {
  return LocalMusicRepository(LocalMusicDatasource());
});