class SimpleFallbackCache {
  static Map<String, dynamic> _memoryCache = {};
  static Map<String, DateTime> _cacheTimestamps = {};

  static Future<List<dynamic>> getVenues(dynamic apiService) async {
    return _getWithMemoryCache('venues', () => apiService.getVenues());
  }

  static Future<List<dynamic>> getSparrings(dynamic apiService) async {
    return _getWithMemoryCache('sparrings', () => apiService.getSparringList());
  }

  static Future<List<dynamic>> getSparringNews(dynamic apiService) async {
    return _getWithMemoryCache('sparring_news', () => apiService.getSparringHistory());
  }

  static Future<List<dynamic>> _getWithMemoryCache(
    String key, 
    Future<dynamic> Function() apiCall
  ) async {
    // Cek memory cache (valid 10 menit)
    if (_memoryCache.containsKey(key)) {
      final lastUpdate = _cacheTimestamps[key];
      if (lastUpdate != null && DateTime.now().difference(lastUpdate).inMinutes < 10) {
        print('🚀 Using memory cached $key');
        return _memoryCache[key];
      }
    }

    // Ambil dari API
    print('🌐 Fetching $key from API');
    try {
      final result = await apiCall();
      if (result['success'] == true) {
        final data = result['data'] ?? [];
        _memoryCache[key] = data;
        _cacheTimestamps[key] = DateTime.now();
        return data;
      }
      return _memoryCache[key] ?? [];
    } catch (e) {
      print(' API error for $key: $e');
      return _memoryCache[key] ?? [];
    }
  }
}