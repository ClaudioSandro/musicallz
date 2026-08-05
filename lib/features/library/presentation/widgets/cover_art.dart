import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class CoverArt extends StatelessWidget {
  const CoverArt({
    super.key,
    this.bytes,
    this.filePath,
    this.size = 48,
    this.radius = 8,
    this.icon = Icons.music_note,
    this.circular = false,
  });

  final Uint8List? bytes;
  final String? filePath;
  final double size;
  final double radius;
  final IconData icon;
  final bool circular;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHigh;
    final child = SizedBox.square(
      dimension: size,
      child: bytes != null
          ? Image.memory(bytes!, fit: BoxFit.cover)
          : filePath != null
              ? Image.file(
                  File(filePath!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _placeholder(color),
                )
              : _placeholder(color),
    );

    if (circular) return ClipOval(child: child);

    return ClipRRect(borderRadius: BorderRadius.circular(radius), child: child);
  }

  Widget _placeholder(Color color) {
    return ColoredBox(
      color: color,
      child: Icon(
        icon,
        size: size * 0.45,
        color: Colors.white.withValues(alpha: 0.6),
      ),
    );
  }
}
