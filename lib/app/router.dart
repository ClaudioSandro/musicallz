import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/musicallz_scaffold.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/library/presentation/screens/album_detail_screen.dart';
import '../features/library/presentation/screens/artist_detail_screen.dart';
import '../features/library/presentation/screens/library_screen.dart';
import '../features/library/presentation/screens/liked_songs_screen.dart';
import '../features/player/presentation/screens/now_playing_screen.dart';
import '../features/playlists/presentation/screens/playlist_detail_screen.dart';
import '../features/search/presentation/search_screen.dart';
import '../features/settings/presentation/settings_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MusicallzScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              name: 'search',
              builder: (context, state) => const SearchScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/library',
              name: 'library',
              builder: (context, state) => const LibraryScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              name: 'settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/artist/:artistId',
      name: 'artist',
      builder: (context, state) => ArtistDetailScreen(
        artistId: state.pathParameters['artistId']!,
      ),
    ),
    GoRoute(
      path: '/album/:albumId',
      name: 'album',
      builder: (context, state) => AlbumDetailScreen(
        albumId: state.pathParameters['albumId']!,
      ),
    ),
    GoRoute(
      path: '/now-playing',
      name: 'now-playing',
      builder: (context, state) => const NowPlayingScreen(),
    ),
    GoRoute(
      path: '/playlist/:playlistId',
      name: 'playlist',
      builder: (context, state) => PlaylistDetailScreen(
        playlistId: int.parse(state.pathParameters['playlistId']!),
      ),
    ),
    GoRoute(
      path: '/liked-songs',
      name: 'liked-songs',
      builder: (context, state) => const LikedSongsScreen(),
    ),
  ],
);
