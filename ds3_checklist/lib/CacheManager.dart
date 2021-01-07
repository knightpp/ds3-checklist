import 'dart:collection';

class CacheManager {
  static HashMap<String, dynamic> _cache = HashMap();

  static V? getValue<K, V>(String key) {
    return _cache[key];
  }

  static void invalidate<K>(K k) {
    _cache.remove(k.toString());
  }

  static Future<T> getOrInit<T>(String key, Future<T> init()) async {
    print("CacheManager got key = $key");
    if (_cache.containsKey(key)) {
      return _cache[key];
    } else {
      final value = await init();
      _cache[key] = value;
      return value;
    }
  }
}
