import 'dart:collection';

class CacheManager {
  static const PLAYTHROUGH_FLATBUFFER = "PT_FLATBUFFER";
  static const PLAYTHROUGH_DB = "PT_DB";

  static const WS_FLATBUFFER = "WS_FLATBUFFER";

  static const ACH_FLATBUFFER = "ACH_FLATBUFFER";
  static const ACH_DB = "ACH_DB";

  static const ARMOR_FLATBUFFER = "ARM_FLATBUFER";

  static const TRADES_FLATBUFFER = "TRADES_FLATBUFFER";

  static const SOULS_FLATBUFFER = "SOULS_FLATBUFFER";

  static final HashMap<String, dynamic> _cache = HashMap();

  static V? getValue<K, V>(String key) {
    return _cache[key];
  }

  static void clearFlatbuffers() {
    [
      PLAYTHROUGH_FLATBUFFER,
      WS_FLATBUFFER,
      ACH_FLATBUFFER,
      ARMOR_FLATBUFFER,
      TRADES_FLATBUFFER,
      SOULS_FLATBUFFER
    ].forEach((element) => invalidate(element));
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
