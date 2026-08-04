import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// A Spotify-like progress slider used by the Now Playing screen.
///
/// It renders a thin rounded track with a fill and a small thumb that only
/// appears while the user is dragging, and supports tap / drag seeking.
class SeekBar extends StatefulWidget {
  const SeekBar({
    super.key,
    required this.position,
    required this.duration,
    this.onChangeEnd,
  });

  final Duration position;
  final Duration duration;
  final ValueChanged<Duration>? onChangeEnd;

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double? _dragFraction;

  double get _fraction {
    if (widget.duration <= Duration.zero) return 0;
    final drag = _dragFraction;
    if (drag != null) return drag.clamp(0.0, 1.0);
    return (widget.position.inMilliseconds /
            widget.duration.inMilliseconds)
        .clamp(0.0, 1.0);
  }

  Duration get _durationAtFraction =>
      Duration(milliseconds: (widget.duration.inMilliseconds * _fraction).round());

  void _updateFromDx(double dx, double width) {
    if (width <= 0) return;
    setState(() => _dragFraction = dx / width);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = 28.0;
        final dragging = _dragFraction != null;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) {
            _updateFromDx(details.localPosition.dx, width);
          },
          onTapUp: (_) {
            widget.onChangeEnd?.call(_durationAtFraction);
            setState(() => _dragFraction = null);
          },
          onHorizontalDragStart: (details) {
            _updateFromDx(details.localPosition.dx, width);
          },
          onHorizontalDragUpdate: (details) {
            _updateFromDx(details.localPosition.dx, width);
          },
          onHorizontalDragEnd: (_) {
            widget.onChangeEnd?.call(_durationAtFraction);
            setState(() => _dragFraction = null);
          },
          child: SizedBox(
            height: height,
            child: Center(
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: dragging ? 5 : 4,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHigh,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: _fraction,
                    child: Container(
                      height: dragging ? 5 : 4,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  if (dragging)
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 120),
                      curve: Curves.easeOut,
                      alignment: Alignment((_fraction * 2) - 1, 0),
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
