class MediaFile {
  final String id;
  final DateTime createdAt;
  final String title;
  final String? description;
  final String contentType;
  final int fileSize;
  final String? presignedUrl;
  final bool isUploaded;
  final String uploadStatus;

  MediaFile({
    required this.id,
    required this.createdAt,
    required this.title,
    this.description,
    required this.contentType,
    required this.fileSize,
    this.presignedUrl,
    required this.isUploaded,
    required this.uploadStatus,
  });

  factory MediaFile.fromJson(Map<String, dynamic> json) {
    return MediaFile(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      title: json['title'] as String,
      description: json['description'] as String?,
      contentType: json['content_type'] as String,
      fileSize: json['file_size'] as int,
      presignedUrl: json['presigned_url'] as String?,
      isUploaded: json['is_uploaded'] as bool,
      uploadStatus: json['upload_status'] as String,
    );
  }

  bool get isImage =>
      contentType.startsWith('image/');

  bool get isVideo =>
      contentType.startsWith('video/');
}
