import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterstitialHelper {
  static InterstitialAd? _interstitialAd;

  static final String _adUnitId = "ca-app-pub-3940256099942544/1033173712";

  static void loadAd() {
    InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          print('INTERSTITIAL AD LOADED SUKSES!!');
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          print('INTERSTITIAL AD GAGAL LOAD: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  static void showAd(BuildContext context) {
    if (_interstitialAd != null) {
      print('MENAMPILKAN INTERSTITIAL AD...');

      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          print('Interstitial ditutup user');
          ad.dispose();
          _interstitialAd = null;
          loadAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          print('Gagal show interstitial: $error');
          ad.dispose();
          _interstitialAd = null;
          loadAd();
        },
      );

      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      print('Ad belum ready, loading & show dalam 2 detik...');
      loadAd();
      Future.delayed(const Duration(seconds: 2), () {
        if (_interstitialAd != null) {
          _interstitialAd!.show();
          _interstitialAd = null;
        }
      });
    }
  }

  static void dispose() {
    _interstitialAd?.dispose();
  }
}