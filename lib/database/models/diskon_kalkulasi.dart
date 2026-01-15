// Model untuk hasil kalkulasi diskon (legacy)
class DiscountCalculation {
  final double originalPrice;
  final double discountAmount;
  final double finalPrice;
  final bool hasDiscount;
  final double discountPercent;

  DiscountCalculation({
    required this.originalPrice,
    required this.discountAmount,
    required this.finalPrice,
    required this.hasDiscount,
    required this.discountPercent,
  });
}
