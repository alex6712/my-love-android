import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/media.dart';
import '../../../core/network/dio_client.dart';

class UploadProgress {
  final String id;
  final String fileName;
  final int fileSize;
  final double progress;
  final UploadStatus status;
  final String? error;

  UploadProgress({
    required this.id,
    required this.fileName,
    required this.fileSize,
    this.progress = 0,
    this.status = UploadStatus.pending,
    this.error,
  });

  UploadProgress copyWith({
    double? progress,
    UploadStatus? status,
    String? error,
  }) {
    return UploadProgress(
      id: id,
      fileName: fileName,
      fileSize: fileSize,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      error: error,
    );
  }
}

enum UploadStatus { pending, uploading, confirming, completed, error }

class UploadNotifier extends StateNotifier<List<UploadProgress>> {
  final Dio _dio;

  UploadNotifier(this._dio) : super([]);

  String _generateId() {
    final r = Random();
    return '${DateTime.now().millisecondsSinceEpoch}-${r.nextInt(9999999)}';
  }

  Future<String> uploadFile({
    required String filePath,
    required String fileName,
    required int fileSize,
    required String mimeType,
    required String title,
    String? description,
  }) async {
    final uploadId = _generateId();
    state = [...state, UploadProgress(
      id: uploadId,
      fileName: fileName,
      fileSize: fileSize,
    )];

    try {
      if (fileSize > MediaConfig.maxFileSizeBytes) {
        throw Exception(
          'Размер файла превышает максимум (${MediaConfig.formatFileSize(MediaConfig.maxFileSizeBytes)})',
        );
      }
      if (!MediaConfig.isSupportedType(mimeType)) {
        throw Exception('Неподдерживаемый тип файла: $mimeType');
      }

      _updateUpload(uploadId, status: UploadStatus.uploading);

      final presignResponse = await _dio.post(
        '/media/files/upload',
        data: {
          'content_type': mimeType,
          'title': title,
          'description': description,
        },
      );
      final fileId = presignResponse.data['url']['file_id'] as String;
      final presignedUrl = presignResponse.data['url']['presigned_url'] as String;

      await _dio.put(
        presignedUrl,
        data: await MultipartFile.fromFile(filePath, filename: fileName),
        options: Options(
          headers: {'Content-Type': mimeType},
          extra: {'noAuth': true},
        ),
        onSendProgress: (sent, total) {
          if (total > 0) {
            _updateUpload(uploadId, progress: sent / total * 100);
          }
        },
      );

      _updateUpload(uploadId, status: UploadStatus.confirming, progress: 100);

      await _dio.post(
        '/media/files/upload/confirm',
        data: {'file_id': fileId},
      );

      _updateUpload(uploadId, status: UploadStatus.completed);
      return fileId;
    } catch (e) {
      _updateUpload(
        uploadId,
        status: UploadStatus.error,
        error: e.toString(),
      );
      rethrow;
    }
  }

  void _updateUpload(String id, {UploadStatus? status, double? progress, String? error}) {
    state = state.map((u) {
      if (u.id != id) return u;
      return u.copyWith(
        status: status,
        progress: progress,
        error: error,
      );
    }).toList();
  }

  void removeUpload(String id) {
    state = state.where((u) => u.id != id).toList();
  }

  void clearCompleted() {
    state = state.where((u) => u.status != UploadStatus.completed).toList();
  }

  bool get isUploading => state.any(
    (u) => u.status == UploadStatus.pending || u.status == UploadStatus.uploading || u.status == UploadStatus.confirming,
  );
}

final uploadProvider = StateNotifierProvider<UploadNotifier, List<UploadProgress>>((ref) {
  return UploadNotifier(ref.read(dioClientProvider).dio);
});
