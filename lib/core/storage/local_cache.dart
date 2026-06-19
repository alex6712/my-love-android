import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final localCacheProvider = Provider<LocalCache>((ref) {
  return LocalCache();
});

class LocalCache {
  static const _boxName = 'app_cache';

  Future<Box> get _box => Hive.openBox(_boxName);

  Future<void> put(String key, dynamic value) async {
    final box = await _box;
    await box.put(key, value);
  }

  Future<dynamic> get(String key) async {
    final box = await _box;
    return box.get(key);
  }

  Future<void> delete(String key) async {
    final box = await _box;
    await box.delete(key);
  }

  Future<void> clear() async {
    final box = await _box;
    await box.clear();
  }
}
