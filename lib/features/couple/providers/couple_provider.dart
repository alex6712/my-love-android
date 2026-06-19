import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../models/couple.dart';

class CoupleState {
  final CoupleInfo? coupleInfo;
  final List<CoupleRequest> incomingRequests;
  final bool isLoading;
  final String? error;

  const CoupleState({
    this.coupleInfo,
    this.incomingRequests = const [],
    this.isLoading = false,
    this.error,
  });

  CoupleState copyWith({
    CoupleInfo? coupleInfo,
    List<CoupleRequest>? incomingRequests,
    bool? isLoading,
    String? error,
  }) {
    return CoupleState(
      coupleInfo: coupleInfo ?? this.coupleInfo,
      incomingRequests: incomingRequests ?? this.incomingRequests,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CoupleNotifier extends StateNotifier<CoupleState> {
  final Dio _dio;

  CoupleNotifier(this._dio) : super(const CoupleState());

  Future<void> loadCouple() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _dio.get('/couple');
      final couple = CoupleInfo.fromJson(response.data);
      state = state.copyWith(coupleInfo: couple, isLoading: false, incomingRequests: []);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> sendRequest(String username) async {
    await _dio.post('/couple/request', data: {'username': username});
  }

  Future<void> acceptRequest(String requestId) async {
    await _dio.patch('/couple/request/accept', data: {'request_id': requestId});
    await loadCouple();
  }

  Future<void> rejectRequest(String requestId) async {
    await _dio.patch('/couple/request/reject', data: {'request_id': requestId});
    await loadCouple();
  }

  Future<void> setRelationshipDate(DateTime date) async {
    await _dio.patch('/couple/date', data: {
      'relationship_date': date.toIso8601String(),
    });
    await loadCouple();
  }

  Future<void> unfriend() async {
    await _dio.delete('/couple');
    await loadCouple();
  }
}

final coupleProvider = StateNotifierProvider<CoupleNotifier, CoupleState>((ref) {
  return CoupleNotifier(ref.read(dioClientProvider).dio);
});
