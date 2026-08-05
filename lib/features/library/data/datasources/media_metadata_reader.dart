import 'package:flutter/services.dart';

import '../models/raw_media_metadata.dart';

abstract class MediaMetadataReader {
  Future<RawMediaMetadata> read(String filePath);
}

class MethodChannelMediaMetadataReader implements MediaMetadataReader {
  static const _channel = MethodChannel('musicallz/metadata');

  @override
  Future<RawMediaMetadata> read(String filePath) async {
    final result = await _channel
        .invokeMapMethod<String, Object?>('readMetadata', {
          'filePath': filePath,
        });

    return RawMediaMetadata(
      title: result?['title'] as String?,
      artist: result?['artist'] as String?,
      album: result?['album'] as String?,
      duration: Duration(milliseconds: (result?['duration'] as num?)?.toInt() ?? 0),
      trackNumber: (result?['track'] as num?)?.toInt(),
      year: (result?['year'] as num?)?.toInt(),
      albumArt: result?['albumArt'] as Uint8List?,
      genre: result?['genre'] as String?,
      composer: result?['composer'] as String?,
      albumArtist: result?['albumArtist'] as String?,
      discNumber: (result?['discNumber'] as num?)?.toInt(),
    );
  }
}