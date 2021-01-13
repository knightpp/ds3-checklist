import 'dart:collection';

class CacheManager {
  static const PLAYTHROUGH_FLATBUFFER = "PT_FLATBUFFER";
  static const PLAYTHROUGH_DB = "PT_DB";
  static final HashMap<String, dynamic> _cache = HashMap();

  static V? getValue<K, V>(String key) {
    return _cache[key];
  }

  static void clearFlatbuffers() {
    [PLAYTHROUGH_FLATBUFFER].forEach((element) => invalidate(element));
  }

  static void invalidate(String k) {
    _cache.remove(k);
  }

  static Future<T> getOrInit<T>(String key, Future<T> init()) async {
    if (_cache.containsKey(key)) {
      return _cache[key];
    } else {
      final value = await init();
      _cache[key] = value;
      return value;
    }
  }
}
