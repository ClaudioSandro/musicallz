import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/musicallz_scaffold.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/library/presentation/screens/album_detail_screen.dart';
import '../features/library/presentation/screens/artist_detail_screen.dart';
import '../features/library/presentation/screens/library_screen.dart';
import '../features/library/presentation/screens/liked_songs_screen.dart';
import '../features/player/presentation/screens/now_playing_screen.dart';
import '../features/player/presentation/screens/queue_screen.dart';
import '../features/playlists/presentation/screens/playlist_detail_screen.dart';
import '../features/search/presentation/genre_detail_screen.dart';
import '../features/search/presentation/search_screen.dart';
import '../features/settings/presentation/appearance_screen.dart';
import '../features/settings/presentation/settings_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Fade + subtle slide used for detail routes. Gentler than the default
/// Material zoom so pushing an album/artist/playlist feels like a soft
/// "expand" without Hero tags (which clash across IndexedStack branches).
Page<void> _softTransition(Widget child) => CustomTransitionPage<void>(
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.03),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
      child: child,
    );

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
      pageBuilder: (context, state) => _softTransition(
        ArtistDetailScreen(
          artistId: state.pathParameters['artistId']!,
        ),
      ),
    ),
    GoRoute(
      path: '/album/:albumId',
      name: 'album',
      pageBuilder: (context, state) => _softTransition(
        AlbumDetailScreen(
          albumId: state.pathParameters['albumId']!,
        ),
      ),
    ),
    GoRoute(
      path: '/now-playing',
      name: 'now-playing',
      pageBuilder: (context, state) =>
          _softTransition(const NowPlayingScreen()),
    ),
    GoRoute(
      path: '/queue',
      name: 'queue',
      pageBuilder: (context, state) =>
          _softTransition(const QueueScreen()),
    ),
    GoRoute(
      path: '/playlist/:playlistId',
      name: 'playlist',
      pageBuilder: (context, state) => _softTransition(
        PlaylistDetailScreen(
          playlistId: int.parse(state.pathParameters['playlistId']!),
        ),
      ),
    ),
    GoRoute(
      path: '/liked-songs',
      name: 'liked-songs',
      pageBuilder: (context, state) =>
          _softTransition(const LikedSongsScreen()),
    ),
    GoRoute(
      path: '/genre/:genreName',
      name: 'genre',
      pageBuilder: (context, state) => _softTransition(
        GenreDetailScreen(
          genreName:
              Uri.decodeComponent(state.pathParameters['genreName']!),
        ),
      ),
    ),
    GoRoute(
      path: '/appearance',
      name: 'appearance',
      pageBuilder: (context, state) =>
          _softTransition(const AppearanceScreen()),
    ),
  ],
);
