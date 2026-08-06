# Musicallz

A modern **Spotify-inspired local music player** built with **Flutter**.

Musicallz is designed for people who want full control over their music library without relying on streaming subscriptions or cloud services. The app scans a dedicated local folder on your Android device, organizes your music automatically, and provides a polished listening experience with playlists, favorites, background playback, and a Spotify-like interface.

> **Current status:** v1.0 / v1.1 in active development.

---

## Screenshots

*Add screenshots of Home, Library, Now Playing, and Playlists here.*

---

## Features

### Local music library

* Scans only `Music/MusicallzStorage`
* Recursive folder scanning
* MP3 metadata extraction
* Automatic organization by **Songs**, **Artists**, and **Albums**
* Multi-artist support (collaborations are indexed correctly)
* Search across songs, artists, and albums

### Music playback

* Play / Pause
* Next / Previous
* Seek and progress bar
* Shuffle
* Repeat (Off / All / One)
* Queue-based playback
* Mini player
* Full **Now Playing** screen

### Background audio

* Playback with screen off
* Android media notification
* Lock screen controls
* Bluetooth / headset controls
* MediaSession integration

### Library management

* Persistent playlists
* Create / Rename / Delete playlists
* Reorder songs inside playlists
* Liked Songs
* Favorites system
* Album and artist detail pages

### UI / UX

* Spotify-inspired dark theme
* Material 3
* Smooth animations
* Hero transitions
* Responsive layouts
* Grid and list views
* Sort options (A-Z, artist, album, year, duration, etc.)

---

## Architecture

Musicallz follows a **feature-based clean architecture**.

```
lib/
  app/
  core/
  features/
    home/
    library/
    player/
    playlists/
    search/
    settings/
  shared/
```

### Tech stack

* **Flutter 3.32+**
* **Dart 3.8+**
* **Riverpod**
* **GoRouter**
* **Isar Database**
* **just_audio**
* **audio_service**
* **audio_session**
* **Flex Color Scheme**
* **Google Fonts (Inter)**

---

## Music folder

Place your music inside:

```
Internal Storage/
└── Music/
    └── MusicallzStorage/
        ├── Album 1/
        │   ├── Track 01.mp3
        │   └── Track 02.mp3
        └── Album 2/
            └── Track 01.mp3
```

Musicallz will automatically detect and index all MP3 files inside this folder.

---

## Getting Started

### Prerequisites

Install:

* Flutter SDK
* Dart SDK (included with Flutter)
* Android Studio or VS Code
* Android SDK
* A physical Android device or emulator

Check installation:

```bash
flutter doctor
```

---

## Installation

Clone the repository:

```bash
git clone https://github.com/ClaudioSandro/musicallz.git
cd musicallz
```

Install dependencies:

```bash
flutter pub get
```

Generate Isar database files:

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Running the app

List available devices:

```bash
flutter devices
```

Run on a connected Android device:

```bash
flutter run
```

Run on a specific device:

```bash
flutter run -d <device_id>
```

Example:

```bash
flutter run -d LLY-NX3
```

---

## Useful Flutter commands

### Analyze the project

```bash
flutter analyze
```

### Run tests

```bash
flutter test
```

### Clean the project

```bash
flutter clean
```

### Reinstall dependencies

```bash
flutter pub get
```

### Build debug APK

```bash
flutter build apk --debug
```

### Build release APK

```bash
flutter build apk --release
```

The generated APK can be found in:

```
build/app/outputs/flutter-apk/
```

---

## Development

Regenerate Isar files after changing database models:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Watch for changes automatically:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

---

## Project goals

### Current version

* Fully offline music player
* Local library management
* Persistent playlists
* Favorites
* Background playback
* Spotify-like UI

### Future ideas

* Theme customization
* Lyrics support
* Sleep timer
* Playback history
* Crossfade
* Android widgets
* Personal music server integration (v2)

---

## Why Musicallz?

Because your music should belong to **you**.

No subscriptions. No ads. No cloud dependency. Just your music library, organized beautifully and available offline anytime.

---

## License

This project is intended for **personal and educational use**.

---

## Author

**ClaudioSandro**

Built with Flutter, Riverpod, Isar, and a lot of late-night debugging.
