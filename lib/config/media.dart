class MediaConfig {
  static const int maxFileSizeBytes = 500 * 1024 * 1024;
  static const List<String> supportedTypes = [
    'image/jpeg',
    'image/png',
    'video/mp4',
    'video/quicktime',
  ];

  static bool isSupportedType(String mimeType) {
    return supportedTypes.contains(mimeType);
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
