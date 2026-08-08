import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_dimens.dart';
import '../../../../core/utils/app_gaps.dart';

/// Result of a successfully submitted playlist dialog.
typedef PlaylistDraft = ({String name, String description});

/// Shows a modern Spotify-style dialog to create or edit a playlist (name +
/// optional description). Name cannot be empty. Returns `null` if dismissed.
Future<PlaylistDraft?> showPlaylistDialog(
  BuildContext context, {
  String title = 'Playlist',
  String confirmLabel = 'Create',
  String? initialName,
  String? initialDescription,
}) {
  return showDialog<PlaylistDraft>(
    context: context,
    builder: (context) => _PlaylistDialog(
      title: title,
      confirmLabel: confirmLabel,
      initialName: initialName,
      initialDescription: initialDescription,
    ),
  );
}

class _PlaylistDialog extends StatefulWidget {
  const _PlaylistDialog({
    required this.title,
    required this.confirmLabel,
    this.initialName,
    this.initialDescription,
  });

  final String title;
  final String confirmLabel;
  final String? initialName;
  final String? initialDescription;

  @override
  State<_PlaylistDialog> createState() => _PlaylistDialogState();
}

class _PlaylistDialogState extends State<_PlaylistDialog> {
  late final TextEditingController _name;
  late final TextEditingController _description;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.initialName);
    _description = TextEditingController(text: widget.initialDescription);
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    HapticFeedback.selectionClick();
    Navigator.of(context).pop(
      (name: _name.text.trim(), description: _description.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: AppDimens.pagePadding),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                gap16,
                TextFormField(
                  controller: _name,
                  autofocus: true,
                  maxLength: 60,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'My Playlist',
                    counterText: '',
                  ),
                  validator: (value) =>
                      (value == null || value.trim().isEmpty)
                          ? 'Give your playlist a name'
                          : null,
                ),
                gap8,
                TextFormField(
                  controller: _description,
                  maxLines: 2,
                  maxLength: 200,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    counterText: '',
                  ),
                ),
                gap16,
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                    child: Text(widget.confirmLabel),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}