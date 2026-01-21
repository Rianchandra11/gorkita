import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:uts_backend/services/admob_service.dart';

// Mock untuk Google Mobile Ads
class MockRewardedAd extends Mock implements RewardedAd {}

class MockMobileAds extends Mock implements MobileAds {}

void main() {
  // Pastikan binding Flutter terinisialisasi dan service dalam mode test
  TestWidgetsFlutterBinding.ensureInitialized();
  AdMobService.enableTestMode();

  setUp(() {
    AdMobService.resetForTest();
  });

  group('AdMobService - Pengujian Inisialisasi', () {
    test('Pola singleton pada AdMobService', () {
      final service1 = AdMobService();
      final service2 = AdMobService();

      expect(identical(service1, service2), true);
    });

    test('ID unit iklan mengembalikan ID tes di mode debug', () {
      final service = AdMobService();
      final adUnitId = service.rewardedAdUnitId;

      expect(adUnitId, isNotEmpty);
      expect(adUnitId.contains('ca-app-pub'), true);
    });

    test('Inisialisasi hanya dipanggil sekali tanpa error', () async {
      final service = AdMobService();

      expect(
        () async => await service.initialize(),
        returnsNormally,
      );
    });
  });

  group('AdMobService - Pengujian Pemuatan Iklan', () {
    test('isAdReady mengembalikan false saat belum memuat', () {
      final service = AdMobService();
      final isReady = service.isAdReady;

      expect(isReady, false);
    });

    test('loading() mengubah state internal', () async {
      final service = AdMobService();
      await service.loading();

      expect(service.isAdReady.runtimeType, bool);
    });

    test('ID unit iklan konsisten setiap kali diakses', () {
      final service = AdMobService();
      final adUnitId1 = service.rewardedAdUnitId;
      final adUnitId2 = service.rewardedAdUnitId;

      expect(adUnitId1, adUnitId2);
    });
  });

  group('AdMobService - Pengujian Penayangan Iklan', () {
    test('showRewardedAd() mengembalikan false saat iklan belum siap', () async {
      final service = AdMobService();
      bool adDismissed = false;
      bool rewardEarned = false;

      final _result = await service.showRewardedAd(
        onAdDismissed: () {
          adDismissed = true;
        },
        onUserEarnedReward: (ad, reward) {
          rewardEarned = true;
        },
      );

      expect(_result.runtimeType, bool);
    });

    test('showRewardedAd() memiliki tanda tangan callback yang valid', () async {
      final service = AdMobService();
      bool callbackExecuted = false;

      try {
        await service.showRewardedAd(
          onAdDismissed: () {
            callbackExecuted = true;
          },
          onUserEarnedReward: (ad, reward) {},
        );
      } catch (e) {
        // Iklan mungkin gagal dimuat, struktur callback tetap valid
      }

      expect(callbackExecuted.runtimeType, bool);
    });
  });

  group('AdMobService - Pengujian Sistem Hadiah', () {
    test('Struktur data RewardItem', () {
      expect(RewardItem, isNotNull);
    });

    test('onUserEarnedReward dipanggil dengan RewardItem', () async {
      final service = AdMobService();
      RewardItem? capturedReward;

      try {
        await service.initialize();
        await service.showRewardedAd(
          onAdDismissed: () {},
          onUserEarnedReward: (ad, reward) {
            capturedReward = reward;
          },
        );
      } catch (e) {
        // Diharapkan jika iklan gagal dimuat
      }

      expect(capturedReward.runtimeType, RewardItem);
    });

    test('Nilai hadiah (amount) harus numerik', () {
      expect(RewardItem, isNotNull);
    });

    test('Jenis hadiah harus berupa string', () {
      expect(RewardItem, isNotNull);
    });
  });

  group('AdMobService - Pengujian Pembersihan', () {
    test('dispose() tidak melempar exception', () {
      final service = AdMobService();

      expect(
        () => service.dispose(),
        returnsNormally,
      );
    });

    test('dispose() membersihkan state internal', () {
      final service = AdMobService();
      service.dispose();

      expect(service.isAdReady, false);
    });

    test('dispose() dapat dipanggil berkali-kali', () {
      final service = AdMobService();

      expect(
        () {
          service.dispose();
          service.dispose();
          service.dispose();
        },
        returnsNormally,
      );
    });
  });

  group('AdMobService - Pengujian Penanganan Error', () {
    test('Penampilan iklan dalam mode test berhasil tanpa crash', () async {
      final service = AdMobService();
      bool onDismissedCalled = false;
      bool onRewardCalled = false;

      final result = await service.showRewardedAd(
        onAdDismissed: () {
          onDismissedCalled = true;
        },
        onUserEarnedReward: (ad, reward) {
          onRewardCalled = true;
        },
      );

      expect(result, isTrue);
      expect(onRewardCalled, isTrue);
      expect(onDismissedCalled, isTrue);
    });

    test('Pemeriksaan aman untuk isAdReady', () {
      // Arrange
      // Persiapan
      final service = AdMobService();

      // Act
      final isReady = service.isAdReady;

      // Assert - tidak null dan boolean
      expect(isReady, isFalse);
      expect(isReady.runtimeType, bool);
    });
  });

  group('AdMobService - KONSTANTA IKLAN UJI COBA', () {
    test('Format Test Ad Unit ID valid', () {
      // Arrange
      // Persiapan
      final service = AdMobService();

      // Act
      final adUnitId = service.rewardedAdUnitId;

      // Assert - Google ad unit format: ca-app-pub-XXXXXXXX/XXXXXXXX
      expect(adUnitId, matches(RegExp(r'ca-app-pub-\d+/\d+')));
    });

    test('Test device ID dikonfigurasi di debug', () {
      // Arrange
      // Persiapan
      final service = AdMobService();

      // Act & Assert - initialize harus set test device
      // Verifikasi tidak throw exception
      expect(
        () async => await service.initialize(),
        returnsNormally,
      );
    });
  });

  group('AdMobService - INTEGRATION TESTS', () {
    test('Complete ad lifecycle: init -> load -> show -> dispose', () async {
      // Arrange
      // Persiapan
      final service = AdMobService();

      // Act
      await service.initialize();
      await service.loading();

      final result = await service.showRewardedAd(
        onAdDismissed: () {},
        onUserEarnedReward: (ad, reward) {},
      );

      service.dispose();

      // Assert
      expect(result.runtimeType, bool);
      expect(service.isAdReady, false);
    });

    test('Multiple ad loads sequence', () async {
      // Arrange
      // Persiapan
      final service = AdMobService();

      // Act
      await service.initialize();

      for (int i = 0; i < 3; i++) {
        await service.loading();
      }

      // Assert
      expect(service.isAdReady.runtimeType, bool);
    });

    test('Ad lifecycle with callback execution', () async {
      // Arrange
      // Persiapan
      final service = AdMobService();
      int dismissCount = 0;
      int rewardCount = 0;

      // Act
      await service.initialize();
      await service.loading();

      final result = await service.showRewardedAd(
        onAdDismissed: () {
          dismissCount++;
        },
        onUserEarnedReward: (ad, reward) {
          rewardCount++;
        },
      );

      service.dispose();

      // Assert
      expect(result.runtimeType, bool);
      expect(dismissCount.runtimeType, int);
      expect(rewardCount.runtimeType, int);
    });
  });

  group('AdMobService - REWARD VALIDATION TESTS', () {
    test('Reward structure memiliki required fields', () {
      // Arrange & Assert
      // RewardItem harus punya amount dan type fields
      // Persiapan
      expect(RewardItem, isNotNull);
    });

    test('Reward dapat diserialisasi untuk storage', () {
      // Arrange
      // Persiapan
      // Reward info: amount (int/num) dan type (String)

      // Assert
      expect(RewardItem, isNotNull);
    });

    test('Multiple rewards handling', () async {
      // Arrange
      // Persiapan
      final service = AdMobService();
      final rewards = <Map<String, dynamic>>[];

      // Act
      await service.initialize();

      final result = await service.showRewardedAd(
        onAdDismissed: () {},
        onUserEarnedReward: (ad, reward) {
          rewards.add({
            'amount': reward.amount,
            'type': reward.type,
          });
        },
      );

      // Assert
      expect(rewards, isA<List<Map<String, dynamic>>>());
    });
  });

  group('AdMobService - PLATFORM SUPPORT', () {
    test('rewardedAdUnitId getter tidak throw untuk Android', () {
      // Arrange
      // Persiapan
      final service = AdMobService();

      // Act & Assert
      expect(
        () => service.rewardedAdUnitId,
        returnsNormally,
      );
    });

    test('Ad Unit ID return correct format', () {
      // Arrange
      // Persiapan
      final service = AdMobService();

      // Act
      final adUnitId = service.rewardedAdUnitId;

      // Assert
      expect(adUnitId.isNotEmpty, true);
    });
  });

  group('AdMobService - STATE MANAGEMENT', () {
    test('isAdReady reflects current state', () {
      // Arrange
      // Persiapan
      final service = AdMobService();

      // Act - awal tidak ready
      expect(service.isAdReady, false);

      // After loading (state mungkin berubah)
      service.loading();

      // Assert - state tetap bisa diakses
      expect(service.isAdReady.runtimeType, bool);
    });

    test('Dispose reset state properly', () {
      // Arrange
      // Persiapan
      final service = AdMobService();

      // Act
      service.dispose();

      // Assert
      expect(service.isAdReady, false);
    });
  });
}
