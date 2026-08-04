import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

/// Decodes the image [bytes] (downscaled) and returns a representative color,
/// used to build the dynamic background of the Now Playing screen.
///
/// Returns null when decoding fails (e.g. invalid bytes or no opaque pixels).
Future<Color?> extractDominantColor(
  Uint8List bytes, {
  int targetSize = 32,
}) async {
  try {
    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: targetSize,
      targetHeight: targetSize,
    );
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    image.dispose();
    if (byteData == null) return null;

    var r = 0.0, g = 0.0, b = 0.0, count = 0.0;
    for (var i = 0; i < byteData.lengthInBytes; i += 4) {
      final alpha = byteData.getUint8(i + 3);
      if (alpha < 128) continue;
      r += byteData.getUint8(i);
      g += byteData.getUint8(i + 1);
      b += byteData.getUint8(i + 2);
      count += 1;
    }
    if (count == 0) return null;

    final average = Color.fromARGB(
      255,
      (r / count).round(),
      (g / count).round(),
      (b / count).round(),
    );
    // Push the average slightly away from mid grey so dark themes stay
    // colourful without becoming washed out.
    return _boost(average);
  } catch (_) {
    return null;
  }
}

Color _boost(Color color) {
  final hsl = HSLColor.fromColor(color);
  final lightness = (hsl.lightness - 0.18).clamp(0.05, 0.75);
  return hsl.withLightness(lightness).toColor();
}
