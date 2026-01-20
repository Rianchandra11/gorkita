import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:uts_backend/database/models/diskon_kalkulasi.dart';
import 'package:uts_backend/database/models/kalkulasi.dart';
import '../database/services/reward_service.dart';

/// Helper class untuk menggunakan hadiah (diskon/cashback) di booking
class DiscountHelper {
  static final RewardService _rewardService = RewardService();

  /// Cek apakah user punya hadiah yang bisa dipakai
  static Future<bool> hasAvailableDiscount(String oderId) async {
    try {
      final data = await _rewardService.getRewardData(oderId);
      return data.canUsePrize;
    } catch (e) {
      if (kDebugMode) debugPrint('Error checking discount: $e');
      return false;
    }
  }

  /// Get hadiah yang dimiliki user
  static Future<RewardPrize?> getAvailablePrize(String oderId) async {
    try {
      final data = await _rewardService.getRewardData(oderId);
      if (data.canUsePrize) {
        return data.wonPrize;
      }
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting prize: $e');
      return null;
    }
  }

  /// Hitung harga dengan hadiah (diskon/cashback)
  static Future<PrizeCalculation> calculatePrize({
    required String oderId,
    required double originalPrice,
  }) async {
    try {
      final data = await _rewardService.getRewardData(oderId);
      
      if (!data.canUsePrize || data.wonPrize == null) {
        return PrizeCalculation(
          originalPrice: originalPrice,
          discountAmount: 0,
          cashbackAmount: 0,
          finalPrice: originalPrice,
          hasPrize: false,
          prize: null,
        );
      }

      final prize = data.wonPrize!;
      double discountAmount = 0;
      double cashbackAmount = 0;
      double finalPrice = originalPrice;

      if (prize.type == RewardType.discount) {
        discountAmount = originalPrice * (prize.value / 100);
        finalPrice = originalPrice - discountAmount;
      } else {
        // Cashback tidak potong harga, tapi user dapat uang kembali
        cashbackAmount = originalPrice * (prize.value / 100);
        finalPrice = originalPrice;
      }

      return PrizeCalculation(
        originalPrice: originalPrice,
        discountAmount: discountAmount,
        cashbackAmount: cashbackAmount,
        finalPrice: finalPrice,
        hasPrize: true,
        prize: prize,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error calculating prize: $e');
      return PrizeCalculation(
        originalPrice: originalPrice,
        discountAmount: 0,
        cashbackAmount: 0,
        finalPrice: originalPrice,
        hasPrize: false,
        prize: null,
      );
    }
  }

  /// Legacy method - Hitung harga dengan diskon
  static Future<DiscountCalculation> calculateDiscount({
    required String oderId,
    required double originalPrice,
  }) async {
    final calc = await calculatePrize(oderId: oderId, originalPrice: originalPrice);
    return DiscountCalculation(
      originalPrice: calc.originalPrice,
      discountAmount: calc.discountAmount,
      finalPrice: calc.finalPrice,
      hasDiscount: calc.hasPrize,
      discountPercent: calc.prize?.value ?? 0,
    );
  }

  /// Gunakan hadiah (panggil saat booking berhasil)
  static Future<PrizeResult> applyPrize({
    required String oderId,
    required double originalPrice,
  }) async {
    return await _rewardService.usePrize(oderId, originalPrice);
  }

  /// Legacy method - Apply diskon
  static Future<DiscountResult> applyDiscount({
    required String oderId,
    required double originalPrice,
  }) async {
    return await _rewardService.useDiscount(oderId, originalPrice);
  }

  /// Show dialog untuk konfirmasi penggunaan hadiah
  static Future<bool> showPrizeConfirmDialog({
    required BuildContext context,
    required PrizeCalculation calc,
  }) async {
    if (calc.prize == null) return false;
    
    final prize = calc.prize!;
    final isDiscount = prize.type == RewardType.discount;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDiscount ? Colors.green.shade50 : Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(prize.icon, style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Gunakan ${prize.name}?',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPriceRow('Harga Normal', calc.originalPrice, isOriginal: !isDiscount),
            
            if (isDiscount) ...[
              _buildPriceRow('${prize.name}', -calc.discountAmount, isDiscount: true),
              const Divider(),
              _buildPriceRow('Total Bayar', calc.finalPrice, isFinal: true),
            ] else ...[
              const Divider(),
              _buildPriceRow('Total Bayar', calc.finalPrice, isFinal: true),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Row(
                  children: [
                    Text('💰', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cashback: Rp ${calc.cashbackAmount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade700,
                            ),
                          ),
                          Text(
                            'Akan dikreditkan setelah transaksi',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade700, size: 18),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Hadiah hanya bisa digunakan 1x',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDiscount ? Colors.green : Colors.purple,
            ),
            child: Text(isDiscount ? 'Gunakan Diskon' : 'Gunakan Cashback'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Legacy dialog
  static Future<bool> showDiscountConfirmDialog({
    required BuildContext context,
    required double originalPrice,
    required double discountAmount,
    required double finalPrice,
  }) async {
    final calc = PrizeCalculation(
      originalPrice: originalPrice,
      discountAmount: discountAmount,
      cashbackAmount: 0,
      finalPrice: finalPrice,
      hasPrize: true,
      prize: const RewardPrize(
        id: 'legacy',
        type: RewardType.discount,
        value: 2.0,
        name: 'Diskon 2%',
        icon: '🏷️',
      ),
    );
    return showPrizeConfirmDialog(context: context, calc: calc);
  }

  static Widget _buildPriceRow(
    String label,
    double amount, {
    bool isOriginal = false,
    bool isDiscount = false,
    bool isFinal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isFinal ? FontWeight.bold : FontWeight.normal,
              fontSize: isFinal ? 16 : 14,
            ),
          ),
          Text(
            isDiscount
                ? '-Rp ${amount.abs().toStringAsFixed(0)}'
                : 'Rp ${amount.toStringAsFixed(0)}',
            style: TextStyle(
              fontWeight: isFinal ? FontWeight.bold : FontWeight.normal,
              fontSize: isFinal ? 16 : 14,
              color: isDiscount
                  ? Colors.green
                  : (isOriginal ? Colors.grey : Colors.black),
              decoration: isOriginal ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }
}






//== algoritma penggunaan hadiah di booking ==
/*

// 1. Di halaman booking, cek apakah ada hadiah:
final hasPrize = await DiscountHelper.hasAvailableDiscount(userId.toString());

// 2. Jika ada, hitung dan tampilkan:
if (hasPrize) {
  final calc = await DiscountHelper.calculatePrize(
    oderId: userId.toString(),
    originalPrice: bookingPrice,
  );
  
  // Tampilkan info hadiah di UI
  if (calc.prize != null) {
    Text('${calc.prize!.icon} ${calc.prize!.name} tersedia!');
    
    if (calc.prize!.type == RewardType.discount) {
      Text('Hemat: Rp ${calc.discountAmount}');
      Text('Harga akhir: Rp ${calc.finalPrice}');
    } else {
      Text('Cashback: Rp ${calc.cashbackAmount}');
    }
  }
}

// 3. Saat user konfirmasi booking dengan hadiah:
final calc = await DiscountHelper.calculatePrize(...);
final confirm = await DiscountHelper.showPrizeConfirmDialog(
  context: context,
  calc: calc,
);

if (confirm) {
  // Apply hadiah
  final result = await DiscountHelper.applyPrize(
    oderId: userId.toString(),
    originalPrice: bookingPrice,
  );
  
  if (result.success) {
    // Lanjut proses booking
    // Jika diskon: bayar result.finalPrice
    // Jika cashback: bayar full, tapi catat cashback result.cashbackAmount
    processBooking(
      priceToPay: result.finalPrice,
      cashbackEarned: result.cashbackAmount,
    );
  }
}

*/
