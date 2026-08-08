import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_dimens.dart';

/// Spotify-style bottom navigation bar.
///
/// Used by the shell ([MusicallzScaffold]) with an explicit [selectedIndex]
/// and [onDestinationSelected] callback, and by detail screens (inside
/// [PlayerBottomShell]) where it navigates to a tab via `context.go`, keeping
/// the mini player and the tab bar visible while browsing the library.
class AppBottomBar extends StatelessWidget {
  const AppBottomBar({super.key, this.selectedIndex, this.onDestinationSelected});

  final int? selectedIndex;
  final ValueChanged<int>? onDestinationSelected;

  static const List<String> _paths = ['/home', '/search', '/library', '/settings'];

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.maybeOf(context);
    final int index;
    if (selectedIndex != null) {
      index = selectedIndex!;
    } else if (router != null) {
      final path = router.state.uri.path;
      final pathIndex = _paths.indexOf(path);
      index = pathIndex < 0 ? 2 : pathIndex;
    } else {
      index = 0;
    }

    return NavigationBar(
      height: AppDimens.navBarHeight,
      backgroundColor: Theme.of(context).colorScheme.surface,
      selectedIndex: index,
      onDestinationSelected: (i) {
        if (onDestinationSelected != null) {
          onDestinationSelected!(i);
        } else if (router != null) {
          router.go(_paths[i]);
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.search_outlined),
          selectedIcon: Icon(Icons.search),
          label: 'Search',
        ),
        NavigationDestination(
          icon: Icon(Icons.library_music_outlined),
          selectedIcon: Icon(Icons.library_music),
          label: 'Your Library',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
