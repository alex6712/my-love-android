import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../models/note.dart';

class NotesState {
  final List<Note> notes;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int offset;
  final NoteType? selectedType;
  final String? error;

  const NotesState({
    this.notes = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.offset = 0,
    this.selectedType,
    this.error,
  });

  NotesState copyWith({
    List<Note>? notes,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? offset,
    NoteType? selectedType,
    String? error,
    bool clearType = false,
  }) {
    return NotesState(
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      offset: offset ?? this.offset,
      selectedType: clearType ? null : (selectedType ?? this.selectedType),
      error: error,
    );
  }
}

class NotesNotifier extends StateNotifier<NotesState> {
  final Dio _dio;
  static const _limit = 10;

  NotesNotifier(this._dio) : super(const NotesState());

  Future<void> loadNotes({NoteType? type}) async {
    state = state.copyWith(isLoading: true, error: null, selectedType: type);
    try {
      final queryParams = StringBuffer('?offset=0&limit=$_limit');
      if (type != null) queryParams.write('&t=${type.apiValue}');

      final response = await _dio.get('/notes${queryParams.toString()}');
      final notes = (response.data['notes'] as List)
          .map((e) => Note.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(
        notes: notes,
        isLoading: false,
        offset: notes.length,
        hasMore: notes.length >= _limit,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final queryParams = StringBuffer('?offset=${state.offset}&limit=$_limit');
      if (state.selectedType != null) queryParams.write('&t=${state.selectedType!.apiValue}');

      final response = await _dio.get('/notes${queryParams.toString()}');
      final notes = (response.data['notes'] as List)
          .map((e) => Note.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(
        notes: [...state.notes, ...notes],
        isLoadingMore: false,
        offset: state.offset + notes.length,
        hasMore: notes.length >= _limit,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  Future<void> createNote({required NoteType type, required String content, String? title}) async {
    final response = await _dio.post('/notes', data: {
      'title': title,
      'content': content,
      'type': type.apiValue,
    });
    final note = Note.fromJson(response.data as Map<String, dynamic>);
    state = state.copyWith(
      notes: [note, ...state.notes],
      offset: state.offset + 1,
    );
  }

  Future<void> deleteNote(String noteId) async {
    await _dio.delete('/notes/$noteId');
    state = state.copyWith(
      notes: state.notes.where((n) => n.id != noteId).toList(),
      offset: (state.offset - 1).clamp(0, state.offset),
    );
  }
}

final notesProvider = StateNotifierProvider<NotesNotifier, NotesState>((ref) {
  return NotesNotifier(ref.read(dioClientProvider).dio);
});
