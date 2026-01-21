import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io' show Platform;

/// AdMobService - Mengelola iklan rewarded
class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  RewardedAd? _rewardedAd;
  bool _isLoading = false;
  bool _fakeAdReady = false;

  // Mode khusus untuk unit test agar tidak memanggil plugin asli
  // PENTING: Set ke false untuk menampilkan REAL ADS
  // Unit test akan set ini ke true melalui enableTestMode()
  static bool _testMode = false;

  @visibleForTesting
  static void enableTestMode() {
    _testMode = true;
  }

  @visibleForTesting
  static void disableTestMode() {
    _testMode = false;
  }

  /// Reset semua state internal untuk keperluan unit test
  @visibleForTesting
  static void resetForTest() {
    _instance._rewardedAd?.dispose();
    _instance._rewardedAd = null;
    _instance._isLoading = false;
    _instance._fakeAdReady = false;
  }

  // Set ke false untuk production
  static const bool _useTestAds = true;

  // Test Ad Unit IDs dari Google 
  static const String _testRewardedAdUnitIdAndroid = 'ca-app-pub-3940256099942544/5224354917';

  static const String _prodRewardedAdUnitIdAndroid = 'ca-app-pub-6257693587711737/4972672720';

  String get rewardedAdUnitId {
    // Di mode test, selalu gunakan test ad unit ID tanpa cek platform
    if (_testMode) {
      return _testRewardedAdUnitIdAndroid;
    }

    if (Platform.isAndroid) {
      return (_useTestAds || kDebugMode)
          ? _testRewardedAdUnitIdAndroid
          : _prodRewardedAdUnitIdAndroid;
    }

    // Untuk platform lain, gunakan test ID Android sebagai fallback
    return _testRewardedAdUnitIdAndroid;
  }

  /// Initialize AdMob
  Future<void> initialize() async {
    if (_testMode) {
      await loading();
      return;
    }

    try {
      await MobileAds.instance.initialize();
      
      // Set test device IDs in debug mode
      if (kDebugMode) {
        MobileAds.instance.updateRequestConfiguration(
          RequestConfiguration(
            testDeviceIds: ['41B70D5775F0544AFA963DAB674394AF'],
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error initializing MobileAds: $e');
    }
    
    await loading();
  }

  Future<void> loading() async {
    if (_isLoading) return;
    _isLoading = true;

    if (_testMode) {
      // Simulasi proses loading tanpa menyentuh plugin
      _fakeAdReady = true;
      _isLoading = false;
      return;
    }

    try {
      await RewardedAd.load(
        adUnitId: rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedAd = ad;
            _isLoading = false;
          },
          onAdFailedToLoad: (error) {
            if (kDebugMode) debugPrint('Error loading ad: ${error.message}');
            _rewardedAd = null;
            _isLoading = false;
          },
        ),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Exception saat loading ad: $e');
      _rewardedAd = null;
      _isLoading = false;
    }
  }

  /// Cek apakah ad siap
  bool get isAdReady => _testMode ? _fakeAdReady : _rewardedAd != null;

  /// Show rewarded ad and call callback based on result
  Future<bool> showRewardedAd({
    required VoidCallback onAdDismissed,
    required void Function(AdWithoutView?, RewardItem) onUserEarnedReward,
  }) async {
    // Jika dalam test mode, simulasi menampilkan iklan dengan reward
    if (_testMode) {
      // Pastikan ad sudah "loaded" di test mode
      if (!_fakeAdReady) {
        await loading();
      }
      
      // Simulasi ad ditampilkan dan user mendapatkan reward
      await Future.delayed(const Duration(seconds: 1));
      
      // Panggil callback reward
      try {
        onUserEarnedReward(null, RewardItem(1, 'coins'));
      } catch (e) {
        if (kDebugMode) debugPrint('Error calling reward callback: $e');
      }
      
      // Simulasi ad dismissed
      await Future.delayed(const Duration(milliseconds: 500));
      onAdDismissed();
      
      return true;
    }

    // Real ad logic untuk production
    if (_rewardedAd == null) {
      await loading();
      
      if (_rewardedAd == null) {
        // Jika real ad gagal, simulasi reward untuk UX yang lebih baik
        await Future.delayed(const Duration(milliseconds: 500));
        try {
          onUserEarnedReward(null, RewardItem(1, 'coins'));
        } catch (e) {
          if (kDebugMode) debugPrint('Error calling reward callback: $e');
        }
        onAdDismissed();
        return true; // Tetap return true agar user dapat reward
      }
    }

    bool earnedReward = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loading();//load to next
        onAdDismissed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        if (kDebugMode) debugPrint('Error showing ad: ${error.message}');
        ad.dispose();
        _rewardedAd = null;
        loading();
      },
    );

    try {
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          earnedReward = true;
          onUserEarnedReward(ad, reward);
        },
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Exception during ad.show(): $e');
      earnedReward = false;
    }

    return earnedReward;
  }

  /// Dispose ads
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _fakeAdReady = false;
  }
}
