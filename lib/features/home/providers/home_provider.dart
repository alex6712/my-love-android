import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';

class DashboardStats {
  final int filesCount;
  final int notesCount;

  DashboardStats({required this.filesCount, required this.notesCount});

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      filesCount: json['files_count'] as int,
      notesCount: json['notes_count'] as int,
    );
  }
}

class HomeNotifier extends StateNotifier<AsyncValue<DashboardStats?>> {
  final Dio _dio;

  HomeNotifier(this._dio) : super(const AsyncData(null));

  Future<void> loadStats() async {
    state = const AsyncLoading();
    try {
      final response = await _dio.get('/dashboard');
      state = AsyncData(DashboardStats.fromJson(response.data));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final homeProvider =
    StateNotifierProvider<HomeNotifier, AsyncValue<DashboardStats?>>((ref) {
  return HomeNotifier(ref.read(dioClientProvider).dio);
});
