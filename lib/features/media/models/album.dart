class Album {
  final String id;
  final DateTime createdAt;
  final String title;
  final String? description;
  final String? coverUrl;
  final bool isPrivate;
  final AlbumCreator creator;

  Album({
    required this.id,
    required this.createdAt,
    required this.title,
    this.description,
    this.coverUrl,
    required this.isPrivate,
    required this.creator,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      title: json['title'] as String,
      description: json['description'] as String?,
      coverUrl: json['cover_url'] as String?,
      isPrivate: json['is_private'] as bool,
      creator: AlbumCreator.fromJson(json['creator']),
    );
  }
}

class AlbumCreator {
  final String id;
  final String username;
  final String? avatarUrl;
  final bool isActive;
  final DateTime createdAt;

  AlbumCreator({
    required this.id,
    required this.username,
    this.avatarUrl,
    required this.isActive,
    required this.createdAt,
  });

  factory AlbumCreator.fromJson(Map<String, dynamic> json) {
    return AlbumCreator(
      id: json['id'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatar_url'] as String?,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class AlbumsWithTotal {
  final List<Album> albums;
  final int total;

  AlbumsWithTotal({required this.albums, required this.total});
}
