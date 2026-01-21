import 'package:flutter_test/flutter_test.dart';
import 'package:uts_backend/services/reward_service.dart';

void main() {
  group('RewardData - Kelayakan Kupon', () {
    test('Belum cukup hari - kupon tidak tersedia', () {
      final data = RewardData(
        oderId: 'user123',
        watchedDays: ['2025-01-01', '2025-01-02', '2025-01-03'],
        hasPrize: false,
        prizeUsed: false,
        wonPrize: null,
        createdAt: DateTime.now(),
      );

      expect(data.progress, 3);
      expect(data.isCompleted, false);
      expect(data.canUsePrize, false);
    });

    test('Sudah cukup hari dengan hadiah - kupon dapat digunakan', () {
      final prize = const RewardPrize(
        id: 'discount_10',
        type: RewardType.discount,
        value: 10.0,
        name: 'Diskon 10%',
        icon: 'GIFT',
      );

      final data = RewardData(
        oderId: 'user123',
        watchedDays: ['2025-01-01', '2025-01-02', '2025-01-03', '2025-01-04', '2025-01-05'],
        hasPrize: true,
        prizeUsed: false,
        wonPrize: prize,
        createdAt: DateTime.now(),
      );

      expect(data.progress >= RewardService.hari, true);
      expect(data.isCompleted, true);
      expect(data.canUsePrize, true);
    });

    test('Hadiah sudah digunakan - tidak dapat digunakan lagi', () {
      final prize = const RewardPrize(
        id: 'discount_10',
        type: RewardType.discount,
        value: 10.0,
        name: 'Diskon 10%',
        icon: 'GIFT',
      );

      final data = RewardData(
        oderId: 'user123',
        watchedDays: ['2025-01-01', '2025-01-02', '2025-01-03', '2025-01-04', '2025-01-05'],
        hasPrize: true,
        prizeUsed: true,
        wonPrize: prize,
        createdAt: DateTime.now(),
      );

      expect(data.isCompleted, true);
      expect(data.canUsePrize, false);
    });
  });

  group('RewardData - Reset Challenge', () {
    test('Reset hadiah untuk tantangan baru', () {
      final prize = const RewardPrize(
        id: 'discount_1',
        type: RewardType.discount,
        value: 1.0,
        name: 'Diskon 1%',
        icon: 'TAG',
      );

      final resetData = RewardData(
        oderId: 'user123',
        watchedDays: [],
        hasPrize: true,
        prizeUsed: true,
        wonPrize: prize,
        createdAt: DateTime.now(),
      );

      expect(resetData.progress, 0);
      expect(resetData.isCompleted, false);
      expect(resetData.canUsePrize, false);
    });

    test('Pengguna dapat memulai tantangan baru setelah reset', () {
      final prize = const RewardPrize(
        id: 'discount_1',
        type: RewardType.discount,
        value: 1.0,
        name: 'Diskon 1%',
        icon: 'TAG',
      );

      final dataAfterReset = RewardData(
        oderId: 'user123',
        watchedDays: ['2026-01-15'],
        hasPrize: true,
        prizeUsed: true,
        wonPrize: prize,
        createdAt: DateTime.now(),
      );

      expect(dataAfterReset.progress, 1);
      expect(dataAfterReset.isCompleted, false);
      expect(dataAfterReset.canUsePrize, false);
    });
  });
}
