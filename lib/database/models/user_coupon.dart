import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uts_backend/database/services/reward_service.dart';


class UserCoupon {
  final String id;
  final String userId;
  final String couponCode;
  final RewardPrize prize;
  final bool isUsed;
  final DateTime createdAt;
  final DateTime? usedAt;
  final String? bookingId;
  final double? discountAmount;
  final double? cashbackAmount;

  UserCoupon({
    required this.id,
    required this.userId,
    required this.couponCode,
    required this.prize,
    required this.isUsed,
    required this.createdAt,
    this.usedAt,
    this.bookingId,
    this.discountAmount,
    this.cashbackAmount,
  });

  factory UserCoupon.fromMap(String id, Map<String, dynamic> map) {
    return UserCoupon(
      id: id,
      userId: map['userId'] ?? '',
      couponCode: map['couponCode'] ?? '',
      prize: RewardPrize.fromMap(map['prize'] ?? {}),
      isUsed: map['isUsed'] ?? false,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      usedAt: (map['usedAt'] as Timestamp?)?.toDate(),
      bookingId: map['bookingId'],
      discountAmount: (map['discountAmount'] ?? 0).toDouble(),
      cashbackAmount: (map['cashbackAmount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'couponCode': couponCode,
      'prize': prize.toMap(),
      'isUsed': isUsed,
      'createdAt': Timestamp.fromDate(createdAt),
      'usedAt': usedAt != null ? Timestamp.fromDate(usedAt!) : null,
      'bookingId': bookingId,
      'discountAmount': discountAmount,
      'cashbackAmount': cashbackAmount,
    };
  }

  UserCoupon copyWith({
    String? id,
    String? userId,
    String? couponCode,
    RewardPrize? prize,
    bool? isUsed,
    DateTime? createdAt,
    DateTime? usedAt,
    String? bookingId,
    double? discountAmount,
    double? cashbackAmount,
  }) {
    return UserCoupon(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      couponCode: couponCode ?? this.couponCode,
      prize: prize ?? this.prize,
      isUsed: isUsed ?? this.isUsed,
      createdAt: createdAt ?? this.createdAt,
      usedAt: usedAt ?? this.usedAt,
      bookingId: bookingId ?? this.bookingId,
      discountAmount: discountAmount ?? this.discountAmount,
      cashbackAmount: cashbackAmount ?? this.cashbackAmount,
    );
  }
}

class CouponUseResult {
  final bool success;
  final String message;
  final double discountAmount;
  final double cashbackAmount;
  final double finalPrice;
  final UserCoupon? couponUsed;

  CouponUseResult({
    required this.success,
    required this.message,
    this.discountAmount = 0,
    this.cashbackAmount = 0,
    required this.finalPrice,
    this.couponUsed,
  });
}
