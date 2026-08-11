import 'package:flutter/material.dart';

/// A single selectable sort option for [SortMenuButton].
typedef SortOption<T> = ({T value, String label, IconData icon});

/// Spotify-style sort control: a small icon button that opens a bottom sheet
/// with the available options for a library section.
class SortMenuButton<T> extends StatelessWidget {
  const SortMenuButton({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<SortOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IconButton(
      tooltip: 'Ordenar',
      onPressed: () => _open(context),
      icon: const Icon(Icons.sort, size: 20),
      visualDensity: VisualDensity.compact,
      color: theme.colorScheme.onSurfaceVariant,
    );
  }

  Future<void> _open(BuildContext context) async {
    final result = await showModalBottomSheet<T>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 8),
              for (final option in options)
                ListTile(
                  leading: Icon(option.icon),
                  title: Text(
                    option.label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: option.value == selected
                      ? Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () => Navigator.of(sheetContext).pop(option.value),
                ),
            ],
          ),
        ),
      ),
    );
    if (result != null && context.mounted) onSelected(result);
  }
}
