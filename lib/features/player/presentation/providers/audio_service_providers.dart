import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../application/audio_handler.dart';

/// The single shared [AudioPlayer] for the whole app.
/// Overridden in `main()` with the instance tied to `audio_service`.
final audioPlayerProvider = Provider<AudioPlayer>(
  (ref) => AudioPlayer(),
);

/// The [MusicallAudioHandler] bridged to the OS media session.
/// Overridden in `main.dart` with the handler registered via `AudioService.init`.
final audioHandlerProvider = Provider<MusicallAudioHandler>(
  (ref) => MusicallAudioHandler(player: ref.watch(audioPlayerProvider)),
);