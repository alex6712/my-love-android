import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/network/dio_client.dart';
import '../../../shared/widgets/image_with_fallback.dart';
import '../models/media_file.dart';

class AlbumDetailScreen extends ConsumerStatefulWidget {
  final String albumId;

  const AlbumDetailScreen({super.key, required this.albumId});

  @override
  ConsumerState<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends ConsumerState<AlbumDetailScreen> {
  List<MediaFile> _files = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final dio = ref.read(dioClientProvider).dio;
      final response = await dio.get('/media/albums/${widget.albumId}');
      final files = (response.data['files'] as List)
          .map((e) => MediaFile.fromJson(e as Map<String, dynamic>))
          .toList();
      setState(() {
        _files = files;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadFiles() async {
    try {
      final dio = ref.read(dioClientProvider).dio;
      final presignResponse = await dio.post(
        '/media/files/upload',
        data: {'content_type': 'image/jpeg', 'title': 'Uploaded from app'},
      );
      final fileId = presignResponse.data['url']['file_id'] as String;
      final presignedUrl =
          presignResponse.data['url']['presigned_url'] as String;

      await dio.put(
        presignedUrl,
        data: 'placeholder',
        options: Options(
          headers: {'Content-Type': 'image/jpeg'},
          extra: {'noAuth': true},
        ),
      );

      await dio.post('/media/files/upload/confirm', data: {'file_id': fileId});

      await _loadFiles();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Ошибка загрузки: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Альбом'),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload),
            onPressed: _pickAndUploadFiles,
            tooltip: 'Загрузить файлы',
          ),
        ],
      ),
      body: _buildContent(isDark),
    );
  }

  Widget _buildContent(bool isDark) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Ошибка: $_error', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFiles,
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    if (_files.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 64,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Нет файлов в альбоме',
              style: TextStyle(
                fontSize: 18,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickAndUploadFiles,
              icon: const Icon(Icons.upload),
              label: const Text('Загрузить файлы'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFiles,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _files.length,
        itemBuilder: (context, index) {
          final file = _files[index];
          return _buildFileItem(file, isDark);
        },
      ),
    );
  }

  Widget _buildFileItem(MediaFile file, bool isDark) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _previewFile(file),
        child: file.isImage
            ? (file.presignedUrl != null
                  ? CachedNetworkImage(
                      imageUrl: file.presignedUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => _buildPlaceholder(isDark),
                      errorWidget: (_, _, _) => ImageWithFallback(),
                    )
                  : ImageWithFallback())
            : Stack(
                alignment: Alignment.center,
                children: [
                  file.presignedUrl != null
                      ? CachedNetworkImage(
                          imageUrl: file.presignedUrl!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          placeholder: (_, _) => _buildPlaceholder(isDark),
                          errorWidget: (_, _, _) => ImageWithFallback(),
                        )
                      : ImageWithFallback(),
                  Icon(
                    Icons.play_circle,
                    size: 48,
                    color: Colors.white.withAlpha(200),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPlaceholder(bool isDark) {
    return Container(
      color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  void _previewFile(MediaFile file) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: file.isImage
            ? CachedNetworkImage(
                imageUrl: file.presignedUrl ?? '',
                fit: BoxFit.contain,
                placeholder: (_, _) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (_, _, _) => const Icon(
                  Icons.broken_image,
                  size: 64,
                  color: Colors.white,
                ),
              )
            : const Center(
                child: Text(
                  'Video preview not available',
                  style: TextStyle(color: Colors.white),
                ),
              ),
      ),
    );
  }
}
