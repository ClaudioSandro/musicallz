import 'dart:io';

import 'package:path/path.dart' as p;

import '../../domain/entities/song.dart';
import '../../domain/exceptions/music_library_exceptions.dart';
import '../../domain/repositories/music_repository.dart';
import '../datasources/local_music_datasource.dart';
import '../models/library_scan_metrics.dart';
import '../models/raw_media_metadata.dart';

class LocalMusicRepository implements MusicRepository {
  LocalMusicRepository(this._datasource);

  static const String unknownTitle = 'Título desconocido';
  static const String unknownArtist = 'Artista desconocido';
  static const String unknownAlbum = 'Álbum desconocido';

  final LocalMusicDatasource _datasource;

  @override
  Future<List<Song>> getSongs() async {
    return _scan();
  }

  @override
  Future<List<Song>> rescan() async {
    return _scan();
  }

  @override
  Future<LibraryScanMetrics?> scanMetrics() async => null;

  @override
  Future<void> recordPlay(String songId) async {}

  Future<List<Song>> _scan() async {
    final root = await _datasource.resolveLibraryRoot();
    if (root == null || !await root.exists()) return const [];

    final List<File> files;
    try {
      files = await _datasource.findMp3Files(root);
    } on FileSystemException {
      throw const MusicLibraryScanException(
        'No se pudo leer la carpeta Music. '
        'Revisa el permiso de almacenamiento.',
      );
    }

    final songs = <Song>[];
    for (final file in files) {
      final metadata = await _datasource.readMetadata(file);
      songs.add(_toSong(file, metadata));
    }

    songs.sort((a, b) {
      final byArtist = a.artist.toLowerCase().compareTo(b.artist.toLowerCase());
      if (byArtist != 0) return byArtist;
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });

    return songs;
  }

  Song _toSong(File file, RawMediaMetadata? metadata) {
    final fileName = p.basenameWithoutExtension(file.path).trim();
    final title = _nonEmpty(metadata?.title) ?? fileName;
    final artist = _nonEmpty(metadata?.artist);
    return Song(
      id: file.path,
      title: _nonEmpty(title) ?? unknownTitle,
      artist: artist ?? unknownArtist,
      album: _nonEmpty(metadata?.album) ?? unknownAlbum,
      duration: metadata?.duration ?? Duration.zero,
      filePath: file.path,
      trackNumber: metadata?.trackNumber,
      year: metadata?.year,
      albumArt: metadata?.albumArt,
      albumArtist: metadata?.albumArtist,
      genre: metadata?.genre,
      composer: metadata?.composer,
      discNumber: metadata?.discNumber,
    );
  }

  String? _nonEmpty(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }
}