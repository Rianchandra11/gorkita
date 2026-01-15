import 'package:uts_backend/database/services/reward_service.dart';

/// Model untuk hasil kalkulasi hadiah
class PrizeCalculation {
  final double originalPrice;
  final double discountAmount;
  final double cashbackAmount;
  final double finalPrice;
  final bool hasPrize;
  final RewardPrize? prize;

  PrizeCalculation({
    required this.originalPrice,
    required this.discountAmount,
    required this.cashbackAmount,
    required this.finalPrice,
    required this.hasPrize,
    this.prize,
  });
  
  /// Untuk backward compatibility
  bool get hasDiscount => hasPrize;
  double get discountPercent => prize?.value ?? 0;
}