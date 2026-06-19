enum NoteType {
  wishlist,
  dream,
  gratitude,
  memory;

  String get apiValue {
    switch (this) {
      case NoteType.wishlist: return 'WISHLIST';
      case NoteType.dream: return 'DREAM';
      case NoteType.gratitude: return 'GRATITUDE';
      case NoteType.memory: return 'MEMORY';
    }
  }

  String get displayName {
    switch (this) {
      case NoteType.wishlist: return 'Хотелки';
      case NoteType.dream: return 'Мечты';
      case NoteType.gratitude: return 'Благодарности';
      case NoteType.memory: return 'Воспоминания';
    }
  }

  static NoteType fromApi(String value) {
    switch (value) {
      case 'WISHLIST': return NoteType.wishlist;
      case 'DREAM': return NoteType.dream;
      case 'GRATITUDE': return NoteType.gratitude;
      case 'MEMORY': return NoteType.memory;
      default: return NoteType.memory;
    }
  }
}

class Note {
  final String id;
  final DateTime createdAt;
  final NoteType type;
  final String title;
  final String content;
  final NoteCreator creator;

  Note({
    required this.id,
    required this.createdAt,
    required this.type,
    required this.title,
    required this.content,
    required this.creator,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      type: NoteType.fromApi(json['type'] as String),
      title: json['title'] as String? ?? '',
      content: json['content'] as String,
      creator: NoteCreator.fromJson(json['creator']),
    );
  }
}

class NoteCreator {
  final String id;
  final String username;
  final String? avatarUrl;

  NoteCreator({
    required this.id,
    required this.username,
    this.avatarUrl,
  });

  factory NoteCreator.fromJson(Map<String, dynamic> json) {
    return NoteCreator(
      id: json['id'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}
