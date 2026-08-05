import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

/// The single Isar instance. Overridden in `main()` with the database opened
/// before `runApp`. Kept in its own file so both the playlists and the library
/// features can depend on it without import cycles.
final isarProvider = Provider<Isar>(
  (_) => throw UnimplementedError('isarProvider must be overridden in main()'),
);
