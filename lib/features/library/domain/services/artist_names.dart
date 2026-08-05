/// Splits a raw ID3 `artist` string (e.g. `"Aimer feat. LiSA"`) into the
/// individual artist names that participated in the track.
///
/// Supported separators (case-insensitive):
/// `,` `;` `&` `×` `/` `|` ` with ` and the feature tokens
/// `feat.` `feat` `ft.` `ft` `featuring`.
///
/// The display string on [Song.artist] keeps the original text untouched; only
/// the index and the artist detail screens use the split names.
class ArtistNames {
  ArtistNames._();

  static final RegExp _featToken = RegExp(
    r'\bfeat(?:uring)?\.?|\bft\.?',
    caseSensitive: false,
  );

  static final RegExp _separator = RegExp(
    r'[&,;×/|]|\bwith\b',
    caseSensitive: false,
  );

  static final RegExp _collapseSpace = RegExp(r'\s+');

  /// Returns the individual artist names in [value], preserving order and
  /// dropping duplicates (case-insensitive). An empty string yields `[]`.
  static List<String> split(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return const [];

    final parts = <String>[];
    for (final chunk in trimmed.split(_featToken)) {
      for (final part in chunk.split(_separator)) {
        final name = part.trim().replaceAll(_collapseSpace, ' ');
        if (name.isNotEmpty) parts.add(name);
      }
    }

    final seen = <String>{};
    return [
      for (final name in parts)
        if (seen.add(name.toLowerCase())) name,
    ];
  }
}
