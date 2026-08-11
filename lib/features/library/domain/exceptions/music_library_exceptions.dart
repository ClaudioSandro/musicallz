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
    return 'Se necesita permiso de almacenamiento para leer tu música.\n'
        'Otorga el acceso e inténtalo de nuevo.';
  }
  if (error is MusicLibraryScanException) {
    return error.message;
  }
  return 'Ocurrió un problema al escanear tu música.\n'
      'Inténtalo de nuevo.';
}