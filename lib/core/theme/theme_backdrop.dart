import 'dart:ui';

import 'package:flutter/material.dart';

import 'theme_extension.dart';
import 'theme_models.dart';

/// Renders the immersive background (used by Now Playing and the detail
/// headers) according to the active [BackgroundStyle] and intensity.
///
/// Backdrops are always blended toward black so the white header text stays
/// readable in both dark and light mode, mirroring how Spotify keeps its
/// Now Playing screen dark even in light mode.
class ThemeBackdrop extends StatelessWidget {
  const ThemeBackdrop({
    super.key,
    required this.child,
    this.image,
    this.artColor,
    this.animationDuration = const Duration(milliseconds: 600),
  });

  final Widget child;

  /// Optional artwork used by the blur styles.
  final ImageProvider? image;

  /// Optional dominant color used by the dynamic style.
  final Color? artColor;

  /// Crossfade duration when the backdrop configuration changes (new song,
  /// different style/intensity or theme).
  final Duration animationDuration;

  @override
  Widget build(BuildContext context) {
    final ext = context.appTheme;
    final k = ext.blendFactor;
    final key = Object.hash(
      ext.backgroundStyle,
      ext.intensity,
      ext.gradientStart,
      ext.gradientEnd,
      artColor,
      image,
    );
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: animationDuration,
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: KeyedSubtree(
              key: ValueKey('backdrop-$key'),
              child: _backdrop(ext, k),
            ),
          ),
        ),
        child,
      ],
    );
  }

  Widget _backdrop(AppThemeExtension ext, double k) {
    switch (ext.backgroundStyle) {
      case BackgroundStyle.solid:
        return ColoredBox(
          color: Color.lerp(ext.gradientStart, Colors.black, k)!,
        );
      case BackgroundStyle.gradient:
        return _gradient(
          Color.lerp(ext.gradientStart, Colors.black, k)!,
          Color.lerp(ext.gradientEnd, Colors.black, (k + 0.18).clamp(0.0, 1.0))!,
        );
      case BackgroundStyle.softBlur:
      case BackgroundStyle.strongBlur:
        return _blur(ext, k);
      case BackgroundStyle.dynamic:
        final base = artColor ?? ext.gradientStart;
        return _gradient(
          Color.lerp(base, Colors.black, k)!,
          Color.lerp(base, Colors.black, (k + 0.2).clamp(0.0, 1.0))!,
        );
    }
  }

  Widget _gradient(Color top, Color bottom) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [top, bottom],
        ),
      ),
    );
  }

  Widget _blur(AppThemeExtension ext, double k) {
    final provider = image;
    if (provider == null) {
      return _gradient(
        Color.lerp(ext.gradientStart, Colors.black, k)!,
        Color.lerp(ext.gradientEnd, Colors.black, (k + 0.18).clamp(0.0, 1.0))!,
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        Image(image: provider, fit: BoxFit.cover),
        BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: ext.intensity.blurSigma,
            sigmaY: ext.intensity.blurSigma,
          ),
          child: ColoredBox(
            color: Color.lerp(ext.gradientStart, Colors.black, k * 0.7)!
                .withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}
