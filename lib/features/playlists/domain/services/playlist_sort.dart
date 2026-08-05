import '../../data/models/playlist.dart';

/// How the Playlists tab can be ordered.
enum PlaylistsSort {
  nameAsc,
  nameDesc,
  createdNew,
  createdOld,
  updatedNew,
  updatedOld,
  songCount,
}

/// Orders [input] playlists according to [sort]. Nulls sort last.
List<Playlist> sortPlaylists(List<Playlist> input, PlaylistsSort sort) {
  final sorted = [...input];
  int byName(Playlist a, Playlist b) =>
      a.name.toLowerCase().compareTo(b.name.toLowerCase());
  int byDateDesc(DateTime? a, DateTime? b) {
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    return b.compareTo(a);
  }

  switch (sort) {
    case PlaylistsSort.nameAsc:
      sorted.sort(byName);
    case PlaylistsSort.nameDesc:
      sorted.sort((a, b) => byName(b, a));
    case PlaylistsSort.createdNew:
      sorted.sort((a, b) => byDateDesc(a.createdAt, b.createdAt));
    case PlaylistsSort.createdOld:
      sorted.sort((a, b) => byDateDesc(b.createdAt, a.createdAt));
    case PlaylistsSort.updatedNew:
      sorted.sort((a, b) => byDateDesc(a.updatedAt, b.updatedAt));
    case PlaylistsSort.updatedOld:
      sorted.sort((a, b) => byDateDesc(b.updatedAt, a.updatedAt));
    case PlaylistsSort.songCount:
      sorted.sort((a, b) {
        if (a.songIds.length != b.songIds.length) {
          return b.songIds.length.compareTo(a.songIds.length);
        }
        return byName(a, b);
      });
  }
  return sorted;
}
