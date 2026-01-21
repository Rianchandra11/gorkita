import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'coupon_service.dart';


class RewardService {
  static final RewardService _instance = RewardService._internal();
  factory RewardService() => _instance;
  RewardService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final Random _random = Random();

  static const int hari = 5;  // Testing: 5 interval x 10 detik = 50 detik  
  static const String _collectionName = 'user_rewards';
  static const List<RewardPrize> hadiah = [
    RewardPrize(id: 'discount_5', type: RewardType.discount, value: 5.0, name: 'Diskon 5%', icon: '🏷️'),
    RewardPrize(id: 'discount_10', type: RewardType.discount, value: 10.0, name: 'Diskon 10%', icon: '🎫'),
    RewardPrize(id: 'cashback_3', type: RewardType.cashback, value: 3.0, name: 'Cashback 3%', icon: '💰'),
    RewardPrize(id: 'cashback_5', type: RewardType.cashback, value: 5.0, name: 'Cashback 5%', icon: '💎'),
    RewardPrize(id: 'cashback_10', type: RewardType.cashback, value: 10.0, name: 'Cashback 10%', icon: '🏆'),
  ];

  /// inisialisasi notifications
  Future<void> initNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _notifications.initialize(initSettings);
  }

  RewardPrize getRandomPrize() {
    return hadiah[_random.nextInt(hadiah.length)];
  }

  Future<RewardData> getRewardData(String oderId) async {
    try {
      // Get dari server untuk fresh data (bukan cache)
      final doc = await _firestore.collection(_collectionName).doc(oderId).get(
        GetOptions(source: Source.server),
      );
      
      if (doc.exists) {
        final rawData = doc.data()!;
        final result = RewardData.fromMap(rawData);
        return result;
      }
      
      // Create new data if not exists
      final newData = RewardData(
        oderId: oderId,
        watchedDays: [],
        hasPrize: false,
        prizeUsed: false,
        createdAt: DateTime.now(),
      );
      
      await _firestore.collection(_collectionName).doc(oderId).set(newData.toMap());
      return newData;
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting reward data: $e');
      return RewardData.empty(oderId);
    }
  }

  /// Check if user has watched ad today
  Future<bool> hasWatchedToday(String oderId) async {
    try {
      final data = await getRewardData(oderId);
      final today = _getDateString(DateTime.now());
      return data.watchedDays.contains(today);
    } catch (e) {
      if (kDebugMode) debugPrint('Error checking watched today: $e');
      return false;
    }
  }


  Future<RewardResult> recordAdWatch(String oderId) async {
    try {
      final data = await getRewardData(oderId);
      final today = _getDateString(DateTime.now());
      
      if (data.watchedDays.contains(today)) {
        return RewardResult(
          success: false,
          message: 'Kamu sudah menonton iklan hari ini. Coba lagi besok!',
          data: data,
        );
      }

      final updatedDays = [...data.watchedDays, today];
      
      final hasCompletedChallenge = updatedDays.length >= hari;
      RewardPrize? wonPrize;
      
      if (hasCompletedChallenge && !data.hasPrize) {
        wonPrize = getRandomPrize();
        
        try {
          await KuponService().addCoupon(
            userId: oderId,
            prize: wonPrize,
          );
        } catch (e) {
          if (kDebugMode) debugPrint('Gagal menambahkan kupon: $e');
        }
      }
      
      final updatedData = RewardData(
        oderId: oderId,
        watchedDays: updatedDays,
        hasPrize: hasCompletedChallenge,
        prizeUsed: data.prizeUsed,
        wonPrize: wonPrize ?? data.wonPrize,
        createdAt: data.createdAt,
        completedAt: hasCompletedChallenge ? DateTime.now() : null,
      );
      
      await _firestore.collection(_collectionName).doc(oderId).update(updatedData.toMap());
       
      await _saveLocalProgress(oderId, updatedDays.length);

      if (hasCompletedChallenge && !data.hasPrize && wonPrize != null) {
        await _showPrizeNotification(wonPrize);
      }
      
      return RewardResult(
        success: true,
        message: (hasCompletedChallenge && wonPrize != null)
          ? 'KuponServiceSelamat! Kamu mendapat ${wonPrize.name}!'
          : 'Hari ke-${updatedDays.length}/$hari selesai! Lanjutkan besok.',
        data: updatedData,
        justCompletedChallenge: hasCompletedChallenge && !data.hasPrize,
        wonPrize: wonPrize,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error recording ad watch: $e');
      return RewardResult(
        success: false,
        message: 'Gagal menyimpan progress: $e',
        data: null,
      );
    }
  }

  /// Use reward (discount/cashback) for booking
  Future<PrizeResult> usePrize(String oderId, double originalPrice) async {
    try {
      final data = await getRewardData(oderId);
      
      if (!data.hasPrize || data.wonPrize == null) {
        return PrizeResult(
          success: false,
          message: 'Kamu belum punya hadiah. Tonton iklan selama 5 hari!',
          discountAmount: 0,
          cashbackAmount: 0,
          finalPrice: originalPrice,
        );
      }
      
      if (data.prizeUsed) {
        return PrizeResult(
          success: false,
          message: 'Hadiah sudah digunakan.',
          discountAmount: 0,
          cashbackAmount: 0,
          finalPrice: originalPrice,
        );
      }
      
      final prize = data.wonPrize!;
      double discountAmount = 0;
      double cashbackAmount = 0;
      double finalPrice = originalPrice;
      
      if (prize.type == RewardType.discount) {
        // Discount: direct price cut
        discountAmount = originalPrice * (prize.value / 100);
        finalPrice = originalPrice - discountAmount;
      } else {
        // Cashback: price stays, cashback calculated
        cashbackAmount = originalPrice * (prize.value / 100);
        finalPrice = originalPrice; // User pays full, gets cashback
      }
      
      // Update prize status to used AND reset watchedDays for next challenge
      await _firestore.collection(_collectionName).doc(oderId).update({
        'prizeUsed': true,
        'prizeUsedAt': FieldValue.serverTimestamp(),
        'watchedDays': [],  // Reset progress untuk challenge baru
      });
      
      final prizeTypeText = prize.type == RewardType.discount ? 'Diskon' : 'Cashback';
      
      return PrizeResult(
        success: true,
        message: prize.type == RewardType.discount 
          ? '${prize.icon} $prizeTypeText ${prize.value}% berhasil diterapkan!'
          : '${prize.icon} Kamu akan mendapat Cashback ${prize.value}% setelah transaksi!',
        discountAmount: discountAmount,
        cashbackAmount: cashbackAmount,
        finalPrice: finalPrice,
        prizeUsed: prize,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error using prize: $e');
      return PrizeResult(
        success: false,
        message: 'Gagal menggunakan hadiah: $e',
        discountAmount: 0,
        cashbackAmount: 0,
        finalPrice: originalPrice,
      );
    }
  }

  /// Legacy method for backward compatibility
  Future<DiscountResult> useDiscount(String oderId, double originalPrice) async {
    final result = await usePrize(oderId, originalPrice);
    return DiscountResult(
      success: result.success,
      message: result.message,
      discountAmount: result.discountAmount,
      finalPrice: result.finalPrice,
    );
  }

  /// Reset progress for next challenge
  Future<void> resetProgress(String oderId) async {
    try {
      // Buat data baru yang fresh
      final newData = RewardData(
        oderId: oderId,
        watchedDays: [],
        hasPrize: false,
        prizeUsed: false,
        wonPrize: null,
        createdAt: DateTime.now(),
        completedAt: null,
      );
      
      // Gunakan SET dengan merge false untuk replace SEMUA field
      await _firestore
          .collection(_collectionName)
          .doc(oderId)
          .set(newData.toMap(), SetOptions(merge: false));
      
      // Clear local progress
      await _saveLocalProgress(oderId, 0);
      
      // Verify update
      await Future.delayed(const Duration(milliseconds: 500));
      final verify = await _firestore
          .collection(_collectionName)
          .doc(oderId)
          .get(GetOptions(source: Source.server));
      
      if (verify.exists) {
        final verifyData = verify.data()!;
        if (kDebugMode) debugPrint('Reward reset verified: hasPrize=${verifyData['hasPrize']}, watchedDays=${verifyData['watchedDays']}');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error resetting progress: $e');
      rethrow;
    }
  }

  /// Get progress from local storage (for fast UI)
  Future<int> getLocalProgress(String oderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('reward_progress_$oderId') ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Save progress to local
  Future<void> _saveLocalProgress(String oderId, int days) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('reward_progress_$oderId', days);
    } catch (e) {
      if (kDebugMode) debugPrint('Error saving local progress: $e');
    }
  }

  /// Show notification when user gets prize
  Future<void> _showPrizeNotification(RewardPrize prize) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'reward_channel',
        'Reward Notifications',
        channelDescription: 'Notifikasi untuk reward dan diskon',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );
      
      const iosDetails = DarwinNotificationDetails();
      
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await _notifications.show(
        1,
        'KuponServiceSelamat! Kamu Dapat Hadiah!',
        'Kamu mendapat ${prize.name}! ${prize.icon} Gunakan sekarang untuk booking.',
        details,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('Error showing notification: $e');
    }
  }


  String _getDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}



enum RewardType { discount, cashback }

/// Reward prize model
class RewardPrize {
  final String id;
  final RewardType type;
  final double value;
  final String name;
  final String icon;

  const RewardPrize({
    required this.id,
    required this.type,
    required this.value,
    required this.name,
    required this.icon,
  });

  factory RewardPrize.fromMap(Map<String, dynamic> map) {
    return RewardPrize(
      id: map['id'] ?? '',
      type: map['type'] == 'cashback' ? RewardType.cashback : RewardType.discount,
      value: (map['value'] ?? 0).toDouble(),
      name: map['name'] ?? '',
      icon: map['icon'] ?? '🎁',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type == RewardType.cashback ? 'cashback' : 'discount',
      'value': value,
      'name': name,
      'icon': icon,
    };
  }
  
  String get description {
    if (type == RewardType.discount) {
      return 'Potongan harga langsung $value%';
    } else {
      return 'Cashback $value% setelah transaksi';
    }
  }
}



class RewardData {
  final String oderId;
  final List<String> watchedDays;
  final bool hasPrize;
  final bool prizeUsed;
  final RewardPrize? wonPrize;
  final DateTime createdAt;
  final DateTime? completedAt;

  RewardData({
    required this.oderId,
    required this.watchedDays,
    required this.hasPrize,
    required this.prizeUsed,
    this.wonPrize,
    required this.createdAt,
    this.completedAt,
  });

  factory RewardData.empty(String oderId) => RewardData(
    oderId: oderId,
    watchedDays: [],
    hasPrize: false,
    prizeUsed: false,
    createdAt: DateTime.now(),
  );

  factory RewardData.fromMap(Map<String, dynamic> map) {
    return RewardData(
      oderId: map['oderId'] ?? '',
      watchedDays: List<String>.from(map['watchedDays'] ?? []),
      hasPrize: map['hasPrize'] ?? map['hasDiscount'] ?? false,
      prizeUsed: map['prizeUsed'] ?? map['discountUsed'] ?? false,
      wonPrize: map['wonPrize'] != null ? RewardPrize.fromMap(map['wonPrize']) : null,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'oderId': oderId,
      'watchedDays': watchedDays,
      'hasPrize': hasPrize,
      'prizeUsed': prizeUsed,
      'wonPrize': wonPrize?.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  int get progress => watchedDays.length;
  bool get isCompleted => progress >= RewardService.hari;
  bool get canUsePrize => hasPrize && !prizeUsed && wonPrize != null;
  
  // Backward compatibility
  bool get hasDiscount => hasPrize;
  bool get discountUsed => prizeUsed;
  bool get canUseDiscount => canUsePrize;
}

class RewardResult {
  final bool success;
  final String message;
  final RewardData? data;
  final bool justCompletedChallenge;
  final RewardPrize? wonPrize;

  RewardResult({
    required this.success,
    required this.message,
    this.data,
    this.justCompletedChallenge = false,
    this.wonPrize,
  });
}

class DiscountResult {
  final bool success;
  final String message;
  final double discountAmount;
  final double finalPrice;

  DiscountResult({
    required this.success,
    required this.message,
    required this.discountAmount,
    required this.finalPrice,
  });
}

class PrizeResult {
  final bool success;
  final String message;
  final double discountAmount;
  final double cashbackAmount;
  final double finalPrice;
  final RewardPrize? prizeUsed;

  PrizeResult({
    required this.success,
    required this.message,
    required this.discountAmount,
    required this.cashbackAmount,
    required this.finalPrice,
    this.prizeUsed,
  });
}
