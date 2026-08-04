import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A single-line text that scrolls left like a moving tape when it overflows
/// its available width. The full text is duplicated inside the strip, so when
/// the first copy scrolls out to the left the second copy enters complete from
/// the right, looping seamlessly. Short texts render as a plain [Text].
class MarqueeText extends StatefulWidget {
  const MarqueeText(
    this.text, {
    super.key,
    this.style,
    this.gap = 48,
    this.initialDelay = const Duration(milliseconds: 700),
  });

  final String text;
  final TextStyle? style;
  final double gap;
  final Duration initialDelay;

  @override
  State<MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<MarqueeText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    Future.delayed(widget.initialDelay, () {
      if (mounted && !_controller.isAnimating && _controller.duration != null) {
        _controller.repeat();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: widget.style),
          textDirection: Directionality.of(context),
          maxLines: 1,
        )..layout();

        final textWidth = painter.width;
        if (textWidth <= width) {
          return Text(widget.text, style: widget.style, maxLines: 1);
        }

        // Slow scroll: ~22 px/s, never below 6 seconds per loop so long titles
        // don't feel rushed.
        final lineHeight = painter.height;
        final loopDistance = textWidth + widget.gap;
        final duration = Duration(
          milliseconds: math.max(6000, (loopDistance * 45).round()),
        );
        _controller.duration = duration;
        if (!_controller.isAnimating) {
          _controller.repeat();
        }

        // The strip is exactly one line tall. The SizedBox pins the marquee's
        // height so the OverflowBox below always receives finite constraints
        // (a Column hands its children unbounded height, which would otherwise
        // make the OverflowBox size itself to infinity and crash).
        return ClipRect(
          child: SizedBox(
            height: lineHeight,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final offset = _controller.value * loopDistance;
                return Transform.translate(
                  offset: Offset(-offset, 0),
                  // OverflowBox lets the tape use its real width without
                  // clamping it to the viewport, so the inner Row never
                  // overflows (no debug stripes) while the ClipRect clips it
                  // cleanly on the sides.
                  child: OverflowBox(
                    alignment: Alignment.topLeft,
                    minWidth: 0,
                    maxWidth: double.infinity,
                    minHeight: 0,
                    maxHeight: lineHeight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(widget.text, style: widget.style, maxLines: 1),
                        SizedBox(width: widget.gap),
                        Text(widget.text, style: widget.style, maxLines: 1),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}