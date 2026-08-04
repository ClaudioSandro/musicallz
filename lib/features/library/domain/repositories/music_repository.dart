import '../entities/song.dart';

abstract class MusicRepository {
  Future<List<Song>> getSongs();
}