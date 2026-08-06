import 'package:flutter/material.dart';

/// A compact toggle to switch a library section between its view modes
/// (e.g. list vs grid, 2-column vs 3-column grid).
class ViewToggle<T> extends StatelessWidget {
  const ViewToggle({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<(T, IconData)> options;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (value, icon) in options)
            InkWell(
              onTap: () => onSelected(value),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 6,
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: value == selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
