import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final appCacheBoxProvider = Provider<Box>((ref) {
  return Hive.box('app_cache');
});

final settingsBoxProvider = Provider<Box>((ref) {
  return Hive.box('settings');
});

final localCacheProvider = Provider<LocalCache>((ref) {
  final box = ref.watch(appCacheBoxProvider);
  return LocalCache(box);
});

class LocalCache {
  final Box _box;

  LocalCache(this._box);

  Future<void> put(String key, dynamic value) async {
    await _box.put(key, value);
  }

  Future<dynamic> get(String key) async {
    return _box.get(key);
  }

  Future<void> delete(String key) async {
    await _box.delete(key);
  }

  Future<void> clear() async {
    await _box.clear();
  }
}
