import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../models/album.dart';

class AlbumsState {
  final List<Album> albums;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int offset;
  final String? error;
  final String? searchQuery;

  const AlbumsState({
    this.albums = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.offset = 0,
    this.error,
    this.searchQuery,
  });

  AlbumsState copyWith({
    List<Album>? albums,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? offset,
    String? error,
    String? searchQuery,
  }) {
    return AlbumsState(
      albums: albums ?? this.albums,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      offset: offset ?? this.offset,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class AlbumsNotifier extends StateNotifier<AlbumsState> {
  final Dio _dio;
  static const _limit = 12;

  AlbumsNotifier(this._dio) : super(const AlbumsState());

  Future<void> loadAlbums() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final queryParams = '?offset=0&limit=$_limit';
      final response = await _dio.get('/media/albums$queryParams');
      final albums = (response.data['albums'] as List)
          .map((e) => Album.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(
        albums: albums,
        isLoading: false,
        offset: albums.length,
        hasMore: albums.length >= _limit,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final queryParams = '?offset=${state.offset}&limit=$_limit';
      final response = await _dio.get('/media/albums$queryParams');
      final albums = (response.data['albums'] as List)
          .map((e) => Album.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(
        albums: [...state.albums, ...albums],
        isLoadingMore: false,
        offset: state.offset + albums.length,
        hasMore: albums.length >= _limit,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  Future<void> searchAlbums(String query) async {
    state = state.copyWith(isLoading: true, error: null, searchQuery: query);
    try {
      final response = await _dio.get(
        '/media/albums/search',
        queryParameters: {'q': query, 'threshold': 0.15, 'limit': 10},
      );
      final albums = (response.data['albums'] as List)
          .map((e) => Album.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(albums: albums, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deleteAlbum(String albumId) async {
    try {
      await _dio.delete('/media/albums/$albumId');
      state = state.copyWith(
        albums: state.albums.where((a) => a.id != albumId).toList(),
      );
    } catch (_) {}
  }

  Future<void> updateAlbum(
    String albumId, {
    String? title,
    String? description,
    bool? isPrivate,
  }) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (isPrivate != null) data['is_private'] = isPrivate;

    await _dio.patch('/media/albums/$albumId', data: data);
  }

  void clearSearch() {
    state = const AlbumsState();
    loadAlbums();
  }
}

final albumsProvider =
    StateNotifierProvider<AlbumsNotifier, AlbumsState>((ref) {
  return AlbumsNotifier(ref.read(dioClientProvider).dio);
});
