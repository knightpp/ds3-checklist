import 'dart:collection';

class CacheManager {
  static HashMap<String, dynamic> _cache = HashMap();

  static V? getValue<K, V>(K k) {
    final key = k.toString();
    return _cache[key];
  }

  static void invalidate<K>(K k) {
    _cache.remove(k.toString());
  }

  static Future<T> getOrInit<T, K>(K k, Future<T> init()) async {
    final key = k.toString();
    print("CacheManager got key = ${key.toString()}");
    if (_cache.containsKey(key)) {
      return _cache[key];
    } else {
      final value = await init();
      _cache[key] = value;
      return value;
    }
  }
}
