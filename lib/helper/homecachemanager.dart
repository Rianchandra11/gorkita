class SimpleCacheManager {
  static final Map<String, dynamic> _memoryCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};

  static Future<List<dynamic>> getVenuesWithCache(
    dynamic apiService, {
    force = false,
  }) async {
    return _getWithMemoryCache(
      'venues',
      () => apiService.getVenues(),
      forceRefresh: force,
    );
  }

  static Future<List<dynamic>> getSparringsWithCache(dynamic apiService,{
    force = false
  }) async {
    return _getWithMemoryCache(
      'sparrings',
      () => apiService.getSparringList(),
      forceRefresh: force,
    );
  }

  static Future<List<dynamic>> getSparringNewsWithCache(
    dynamic apiService,{
      force = false
    }
  ) async {
    return _getWithMemoryCache(
      'sparring_news',
      () => apiService.getSparringHistory(),forceRefresh: force
    );
  }

  static Future<List<dynamic>> _getWithMemoryCache(
    String key,
    Future<dynamic> Function() apiCall, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _memoryCache.containsKey(key)) {
      final lastUpdate = _cacheTimestamps[key];
      if (lastUpdate != null &&
          DateTime.now().difference(lastUpdate).inMinutes < 10) {
        print('memory cache $key: ${_memoryCache[key].length} item');
        return _memoryCache[key];
      }
    }

    print('Fetch $key dari API...');
    try {
      final result = await apiCall();
      if (result['success'] == true) {
        final data = result['data'] ?? [];
        _memoryCache[key] = data;
        _cacheTimestamps[key] = DateTime.now();
        print('Cache $key: ${data.length} item');
        return data;
      } else {
        print('API error dari $key: ${result['message']}');
        return _memoryCache[key] ?? [];
      }
    } catch (e) {
      print('API call failed for $key: $e');
      return _memoryCache[key] ?? [];
    }
  }

  static Future<Map<String, dynamic>> forceRefreshAllData(
    dynamic apiService,
  ) async {
    try {
      print('refresh all data from API...');

      final results = await Future.wait([
        _forceRefreshVenues(apiService),
        _forceRefreshSparrings(apiService),
        _forceRefreshSparringNews(apiService),
      ], eagerError: false);

      print('🎉 Force refresh completed!');

      return {
        'venues': results[0],
        'sparrings': results[1],
        'sparringNews': results[2],
        'success': true,
      };
    } catch (e) {
      print('Force refresh failed: $e');
      return {
        'venues': [],
        'sparrings': [],
        'sparringNews': [],
        'success': false,
      };
    }
  }

  static Future<List<dynamic>> _forceRefreshVenues(dynamic apiService) async {
    try {
      final result = await apiService.getVenues();
      if (result['success'] == true) {
        final venues = result['data'] ?? [];
        _memoryCache['venues'] = venues;
        _cacheTimestamps['venues'] = DateTime.now();
        return venues;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<dynamic>> _forceRefreshSparrings(
    dynamic apiService,
  ) async {
    try {
      final result = await apiService.getSparringList();
      if (result['success'] == true) {
        final sparrings = result['data'] ?? [];
        _memoryCache['sparrings'] = sparrings;
        _cacheTimestamps['sparrings'] = DateTime.now();
        return sparrings;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<dynamic>> _forceRefreshSparringNews(
    dynamic apiService,
  ) async {
    try {
      final result = await apiService.getSparringHistory();
      if (result['success'] == true && result['data'] != null) {
        final news = result['data'] is List ? result['data'] : [];
        _memoryCache['sparring_news'] = news;
        _cacheTimestamps['sparring_news'] = DateTime.now();
        return news;
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  static void clearCache() async {
    _memoryCache.clear();
    _cacheTimestamps.clear();
    print('🗑️ Memory cache cleared');
    await Future.delayed(Duration(milliseconds: 200));
  }

  static Map<String, dynamic> getCacheStats() {
    return {
      'venues_count': _memoryCache['venues']?.length ?? 0,
      'sparrings_count': _memoryCache['sparrings']?.length ?? 0,
      'news_count': _memoryCache['sparring_news']?.length ?? 0,
      'total_cached_items':
          (_memoryCache['venues']?.length ?? 0) +
          (_memoryCache['sparrings']?.length ?? 0) +
          (_memoryCache['sparring_news']?.length ?? 0),
    };
  }
}
