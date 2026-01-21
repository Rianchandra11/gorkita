import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uts_backend/model/user_coupon.dart';
import 'dart:math';
import 'reward_service.dart';


class KuponService {
  static final KuponService _instance = KuponService._internal();
  factory KuponService() => _instance;
  KuponService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'user_coupons';

  /// Pastikan setiap user punya 1 kupon diskon 10% jika belum ada kupon sama sekali
  Future<void> ensureWelcomeCoupon(String userId) async {
    final snapshot = await _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .get();
    final coupons = snapshot.docs
        .map((doc) => UserCoupon.fromMap(doc.id, doc.data()))
        .where((coupon) => !coupon.isUsed)
        .toList();
    if (coupons.isEmpty) {
      // Buat kupon diskon 10%
      final prize = RewardPrize(
        id: 'welcome_discount_10',
        type: RewardType.discount,
        value: 10.0,
        name: 'Diskon 10% (Welcome)',
        icon: '🎉',
      );
      await addCoupon(userId: userId, prize: prize);
    }
  }

  /// Generate kode kupon unik
  String _generateCouponCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final code = List.generate(8, (index) => chars[random.nextInt(chars.length)]).join();
    return 'PROMO$code';
  }

  /// Tambah kupon baru untuk user (dipanggil saat user selesai tantangan 5 hari)
  Future<UserCoupon> addCoupon({
    required String userId,
    required RewardPrize prize,
  }) async {
    try {
      final couponCode = _generateCouponCode();
      final now = DateTime.now();
      
      final coupon = UserCoupon(
        id: '', // akan diisi setelah add
        userId: userId,
        couponCode: couponCode,
        prize: prize,
        isUsed: false,
        createdAt: now,
      );

      final docRef = await _firestore.collection(_collectionName).add(coupon.toMap());
      
      return coupon.copyWith(id: docRef.id);
    } catch (e) {
      if (kDebugMode) debugPrint('Error adding coupon: $e');
      rethrow;
    }
  }

  /// Get semua kupon user yang tersedia (belum dipakai)
  /// Menggunakan query sederhana tanpa orderBy untuk menghindari composite index
  Stream<List<UserCoupon>> getAvailableCoupons(String userId) {
    return _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          // Filter di client side dan sort manual
          final coupons = snapshot.docs
              .map((doc) => UserCoupon.fromMap(doc.id, doc.data()))
              .where((coupon) => !coupon.isUsed)
              .toList();
          // Sort by createdAt descending
          coupons.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return coupons;
        });
  }

  /// Get semua kupon user yang sudah dipakai
  Stream<List<UserCoupon>> getUsedCoupons(String userId) {
    return _firestore
        .collection(_collectionName)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          // Filter di client side dan sort manual
          final coupons = snapshot.docs
              .map((doc) => UserCoupon.fromMap(doc.id, doc.data()))
              .where((coupon) => coupon.isUsed)
              .toList();
          // Sort by usedAt descending
          coupons.sort((a, b) {
            final aDate = a.usedAt ?? DateTime(1970);
            final bDate = b.usedAt ?? DateTime(1970);
            return bDate.compareTo(aDate);
          });
          return coupons;
        });
  }

  /// Get kupon berdasarkan kode
  Future<UserCoupon?> getCouponByCode(String couponCode) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('couponCode', isEqualTo: couponCode)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return UserCoupon.fromMap(
        snapshot.docs.first.id,
        snapshot.docs.first.data(),
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting coupon by code: $e');
      return null;
    }
  }

  /// Get satu kupon tersedia untuk user (untuk checkout)
  Future<UserCoupon?> getFirstAvailableCoupon(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .get();

      if (snapshot.docs.isEmpty) return null;

      // Filter dan sort di client side
      final coupons = snapshot.docs
          .map((doc) => UserCoupon.fromMap(doc.id, doc.data()))
          .where((coupon) => !coupon.isUsed)
          .toList();
      
      if (coupons.isEmpty) return null;
      
      // Sort by createdAt ascending (yang paling lama dulu)
      coupons.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return coupons.first;
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting available coupon: $e');
      return null;
    }
  }

  /// Gunakan kupon
  Future<CouponUseResult> useCoupon({
    required String couponId,
    required double originalPrice,
    String? bookingId,
  }) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(couponId).get();
      
      if (!doc.exists) {
        return CouponUseResult(
          success: false,
          message: 'Kupon tidak ditemukan',
          finalPrice: originalPrice,
        );
      }

      final coupon = UserCoupon.fromMap(doc.id, doc.data()!);

      if (coupon.isUsed) {
        return CouponUseResult(
          success: false,
          message: 'Kupon sudah digunakan',
          finalPrice: originalPrice,
        );
      }

      final prize = coupon.prize;
      double discountAmount = 0;
      double cashbackAmount = 0;
      double finalPrice = originalPrice;

      if (prize.type == RewardType.discount) {
        discountAmount = originalPrice * (prize.value / 100);
        finalPrice = originalPrice - discountAmount;
      } else {
        cashbackAmount = originalPrice * (prize.value / 100);
        finalPrice = originalPrice;
      }

      // Update kupon sebagai terpakai
      await _firestore.collection(_collectionName).doc(couponId).update({
        'isUsed': true,
        'usedAt': FieldValue.serverTimestamp(),
        'bookingId': bookingId,
        'discountAmount': discountAmount,
        'cashbackAmount': cashbackAmount,
      });

      return CouponUseResult(
        success: true,
        message: prize.type == RewardType.discount
            ? '${prize.icon} ${prize.name} berhasil diterapkan!'
            : '${prize.icon} Kamu akan mendapat ${prize.name} setelah transaksi!',
        discountAmount: discountAmount,
        cashbackAmount: cashbackAmount,
        finalPrice: finalPrice,
        couponUsed: coupon,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error using coupon: $e');
      return CouponUseResult(
        success: false,
        message: 'Gagal menggunakan kupon: $e',
        finalPrice: originalPrice,
      );
    }
  }

  /// Hitung total kupon tersedia
  Future<int> getAvailableCouponCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .get();

      // Filter di client side
      final count = snapshot.docs
          .map((doc) => doc.data())
          .where((data) => data['isUsed'] == false)
          .length;

      return count;
    } catch (e) {
      if (kDebugMode) debugPrint('Error counting coupons: $e');
      return 0;
    }
  }
}
