import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Animated 3-bar "equalizer" used to indicate that a song is currently
/// playing. Falls back to a static state when [playing] is false.
class EqualizerBars extends StatefulWidget {
  const EqualizerBars({
    super.key,
    this.playing = true,
    this.size = 16,
    this.color = AppColors.accent,
  });

  final bool playing;
  final double size;
  final Color color;

  @override
  State<EqualizerBars> createState() => _EqualizerBarsState();
}

class _EqualizerBarsState extends State<EqualizerBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.playing) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant EqualizerBars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.playing && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.playing && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0.3;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(3, (index) {
            final phase = (t + index * 0.28) % 1.0;
            final factor = widget.playing
                ? (math.sin(phase * 2 * math.pi) * 0.5 + 0.5)
                : 0.35;
            final height = widget.size * (0.35 + 0.65 * factor);
            return Container(
              width: widget.size * 0.28,
              height: height,
              margin: EdgeInsets.symmetric(horizontal: widget.size * 0.07),
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(99),
              ),
            );
          }),
        );
      },
    );
  }
}