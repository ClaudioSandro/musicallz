class MusicLibraryPermissionDeniedException implements Exception {
  const MusicLibraryPermissionDeniedException();
}

class MusicLibraryScanException implements Exception {
  const MusicLibraryScanException(this.message);

  final String message;

  @override
  String toString() => message;
}

String describeLibraryError(Object error) {
  if (error is MusicLibraryPermissionDeniedException) {
    return 'Storage permission is required to read your music.\n'
        'Please grant access and try again.';
  }
  if (error is MusicLibraryScanException) {
    return error.message;
  }
  return 'Something went wrong while scanning your music.\n'
      'Please try again.';
}