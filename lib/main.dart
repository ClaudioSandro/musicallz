import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';

import 'app/app.dart';
import 'features/player/application/audio_handler.dart';
import 'features/player/application/session_store.dart';
import 'features/player/presentation/providers/audio_service_providers.dart';
import 'features/player/presentation/providers/player_providers.dart';
import 'features/playlists/data/datasources/isar_database.dart';
import 'features/playlists/presentation/providers/isar_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Single shared AudioPlayer. It is handed to BOTH the audio_service handler
  // and the PlayerController (via the overridden providers below), so there is
  // exactly one player for the whole app.
  final audioPlayer = AudioPlayer();

  final audioHandler = await _initAudioHandler(audioPlayer);

  // Persistent library (playlists + favorites) opened before the UI builds.
  final isar = await IsarDatabase.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        audioPlayerProvider.overrideWithValue(audioPlayer),
        audioHandlerProvider.overrideWithValue(audioHandler),
        sessionStoreProvider.overrideWithValue(IsarSessionStore(isar)),
        isarProvider.overrideWithValue(isar),
      ],
      child: const MusicallzApp(),
    ),
  );
  // Ask for notification permission so Android 13+ shows the media playback
  // notification posted by the foreground service.
  _requestNotificationPermission();
}

/// Requests POST_NOTIFICATIONS on Android 13+ so the background playback
/// notification is actually displayed.
Future<void> _requestNotificationPermission() async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
  final status = await Permission.notification.status;
  if (status != PermissionStatus.granted &&
      status != PermissionStatus.permanentlyDenied) {
    await Permission.notification.request();
  }
}

/// Registers the handler with audio_service so playback keeps working in the
/// background with a notification.
///
/// Requires `MainActivity` to extend `AudioServiceActivity` (the shared
/// FlutterEngine that audio_service provides); otherwise `init` throws. The
/// timeout is only a safety net so a hostile device can never block startup:
/// if init fails/times out we fall back to a plain handler, which still plays
/// audio but without the background notification.
Future<MusicallAudioHandler> _initAudioHandler(AudioPlayer player) async {
  try {
    return await AudioService.init(
      builder: () => MusicallAudioHandler(player: player),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.musicallz.channel.audio',
        androidNotificationChannelName: 'Musicallz',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
        androidNotificationIcon: 'mipmap/ic_launcher',
      ),
    ).timeout(const Duration(seconds: 15));
  } catch (e) {
    debugPrint('[main] audio service init failed/timeout: $e');
    return MusicallAudioHandler(player: player);
  }
}
