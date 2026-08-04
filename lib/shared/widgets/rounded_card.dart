import 'package:flutter/material.dart';

import '../../core/constants/app_dimens.dart';

class RoundedCard extends StatelessWidget {
  const RoundedCard({
    super.key,
    this.child,
    this.padding,
    this.onTap,
    this.height,
    this.width,
    this.color,
  });

  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final double? height;
  final double? width;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      height: height,
      width: width,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      ),
      child: child,
    );

    if (onTap == null) return card;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.cardRadius),
      child: card,
    );
  }
}
