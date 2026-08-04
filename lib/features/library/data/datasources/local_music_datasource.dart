import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/raw_media_metadata.dart';
import 'media_metadata_reader.dart';

class LocalMusicDatasource {
  LocalMusicDatasource({MediaMetadataReader? metadataReader})
      : _metadataReader =
            metadataReader ?? MethodChannelMediaMetadataReader();

  static const String musicFolderName = 'Music';
  static const String storageFolderName = 'MusicallzStorage';

  final MediaMetadataReader _metadataReader;

  Future<Directory?> resolveLibraryRoot() async {
    if (kIsWeb) return null;

    if (Platform.isAndroid) {
      return Directory(
        '/storage/emulated/0/$musicFolderName/$storageFolderName',
      );
    }

    final home = Platform.environment['USERPROFILE'] ??
        Platform.environment['HOME'];
    if (home == null || home.isEmpty) return null;

    return Directory('$home/$musicFolderName/$storageFolderName');
  }

  Future<List<File>> findMp3Files(Directory root) async {
    final files = <File>[];
    await for (final entity in root.list(recursive: true, followLinks: false)) {
      if (entity is File && entity.path.toLowerCase().endsWith('.mp3')) {
        files.add(entity);
      }
    }
    return files;
  }

  Future<RawMediaMetadata?> readMetadata(File file) async {
    try {
      return await _metadataReader.read(file.path);
    } on Exception {
      return null;
    }
  }
}