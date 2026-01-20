import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../database/services/reward_service.dart';
import '../database/services/admob_service.dart';
import '../pages/kupon_saya_page.dart';

class RewardProgressWidget extends StatefulWidget {
  final String oderId;
  final VoidCallback? onDiscountEarned;
  final bool showCompact;

  const RewardProgressWidget({
    super.key,
    required this.oderId,
    this.onDiscountEarned,
    this.showCompact = false,
  });

  @override
  State<RewardProgressWidget> createState() => _RewardProgressWidgetState();
}

class _RewardProgressWidgetState extends State<RewardProgressWidget>
    with SingleTickerProviderStateMixin {
  final RewardService _rewardService = RewardService();
  final AdMobService _adMobService = AdMobService();

  static const _primary = Color(0xFF1B5E20);
  static const _secondary = Color(0xFF4CAF50);
  static const _surface = Color(0xFFF1F8E9);

  late AnimationController _animController;
  late Animation<double> _pulseAnim;

  RewardData? _rewardData;
  bool _isLoading = true;
  bool _isWatchingAd = false;
  bool _hasWatchedToday = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _loadData();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Force read dari server, bypass cache sepenuhnya
      final data = await _rewardService.getRewardData(widget.oderId);
      final watchedToday = await _rewardService.hasWatchedToday(widget.oderId);
      if (mounted) {
        setState(() {
          _rewardData = data;
          _hasWatchedToday = watchedToday;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error in _loadData: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _watchAd() async {
    if (_hasWatchedToday || _isWatchingAd) return;
    setState(() => _isWatchingAd = true);

    final success = await _adMobService.showRewardedAd(
      onAdDismissed: () {},
      onUserEarnedReward: (ad, reward) async {
        final result = await _rewardService.recordAdWatch(widget.oderId);
        if (mounted) {
          setState(() {
            _rewardData = result.data;
            _hasWatchedToday = true;
            _isWatchingAd = false;
          });
          if (result.justCompletedChallenge && result.wonPrize != null) {
            _showPrizeDialog(result.wonPrize!);
            widget.onDiscountEarned?.call();
          } else {
            _showSnackBar(result.message, result.success);
          }
        }
      },
    );

    if (!success && mounted) {
      setState(() => _isWatchingAd = false);
      _showSnackBar('Gagal menampilkan iklan', false);
    }
  }

  void _showSnackBar(String message, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? _primary : Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _navigateToKuponSaya() {
    // Navigate to Kupon Saya page
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => KuponSayaPage(userId: widget.oderId),
      ),
    ).then((_) {
      // Reset progress for next challenge when returning from kupon saya
      _resetChallengeAndReload();
    });
  }

  Future<void> _resetChallengeAndReload() async {
    try {
      // Langsung set state ke loading dan clear data
      if (mounted) {
        setState(() {
          _isLoading = true;
          _rewardData = null;
          _hasWatchedToday = false;
        });
      }
      
      // Reset di Firestore
      await _rewardService.resetProgress(widget.oderId);
      
      // Wait untuk Firestore consistency
      await Future.delayed(const Duration(seconds: 2));
      
      // Load data baru dengan fresh request
      if (mounted) {
        await _loadData();
        _showSnackBar('Challenge baru dimulai! 🚀', true);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error resetting challenge: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar('Error: $e', false);
      }
    }
  }


  void _showPrizeDialog(RewardPrize prize) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: _surface,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(prize.icon, style: const TextStyle(fontSize: 40)),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Selamat! 🎉',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                prize.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _secondary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  prize.type == RewardType.cashback
                      ? 'Cashback ${prize.value.toInt()}%'
                      : 'Diskon ${prize.value.toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                prize.description,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Pop dialog dulu
                    Navigator.pop(ctx);
                    // Tunggu dialog ditutup, baru navigate
                    Future.delayed(const Duration(milliseconds: 300), () {
                      _navigateToKuponSaya();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Lihat di Kupon Saya',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: _primary));
    }
    return widget.showCompact ? _buildCompact() : _buildFull();
  }

  Widget _buildCompact() {
    final progress = _rewardData?.progress ?? 0;
    final hasPrize = _rewardData?.canUsePrize ?? false;
    final prize = _rewardData?.wonPrize;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: hasPrize ? _secondary : _primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            hasPrize ? (prize?.icon ?? '🎁') : '🎁',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 6),
          Text(
            hasPrize ? 'HADIAH!' : '$progress/5',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFull() {
    final progress = _rewardData?.progress ?? 0;
    final hasPrize = _rewardData?.hasPrize ?? false;  // Gunakan hasPrize langsung, bukan canUsePrize
    final prizeUsed = _rewardData?.prizeUsed ?? false;
    final prize = _rewardData?.wonPrize;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: hasPrize ? _secondary : _primary,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (context, child) => Transform.scale(
                    scale: hasPrize ? _pulseAnim.value : 1.0,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: hasPrize
                            ? Text(prize?.icon ?? '🎁', style: const TextStyle(fontSize: 26))
                            : const Icon(Icons.card_giftcard, color: _primary, size: 26),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasPrize ? 'Hadiah Tersedia!' : 'Tantangan 5 Hari',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasPrize
                            ? prize?.name ?? 'Gunakan saat booking'
                            : 'Nonton iklan harian, raih hadiah',
                        style: TextStyle(
                          color: Colors.white.withAlpha(220),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildProgressIndicator(progress),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    hasPrize
                        ? '${prize?.name} siap digunakan!'
                        : '$progress dari ${RewardService.hari} hari selesai',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (!hasPrize) ...[
                  const SizedBox(height: 16),
                  _buildWatchButton(progress),
                ],
                if (hasPrize && !prizeUsed) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFE5B4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Color(0xFFFFC107), width: 1.5),
                    ),
                    child: const Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, color: Color(0xFFFBC02D), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Tantangan Selesai! ✨',
                              style: TextStyle(
                                color: Color(0xFF856404),
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Tunggu tantangan berikutnya 🎉',
                          style: TextStyle(
                            color: Color(0xFF856404),
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
                if (prizeUsed) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: _primary, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Hadiah sudah digunakan',
                          style: TextStyle(color: _primary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(int progress) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(RewardService.hari, (i) {
        final done = i < progress;
        final today = i == progress && !_hasWatchedToday;
        return Column(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? _secondary : Colors.grey.shade100,
                border: today ? Border.all(color: _secondary, width: 2.5) : null,
              ),
              child: Center(
                child: done
                    ? const Icon(Icons.check, color: Colors.white, size: 22)
                    : Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: today ? _secondary : Colors.grey.shade400,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Hari ${i + 1}',
              style: TextStyle(
                color: done ? _primary : Colors.grey.shade500,
                fontSize: 10,
                fontWeight: done ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildWatchButton(int progress) {
    final disabled = _hasWatchedToday || _isWatchingAd;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: disabled ? null : _watchAd,
        style: ElevatedButton.styleFrom(
          backgroundColor: _secondary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isWatchingAd)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            else
              Icon(_hasWatchedToday ? Icons.check_circle : Icons.play_circle_fill, size: 20),
            const SizedBox(width: 8),
            Text(
              _isWatchingAd
                  ? 'Memuat...'
                  : _hasWatchedToday
                      ? 'Sudah Nonton Hari Ini'
                      : 'Nonton Iklan (Hari ${progress + 1})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class PrizeBadge extends StatelessWidget {
  final RewardPrize? prize;
  final bool hasPrize;
  final VoidCallback? onTap;

  const PrizeBadge({super.key, this.prize, required this.hasPrize, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (!hasPrize || prize == null) return const SizedBox.shrink();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(prize!.icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              prize!.type == RewardType.cashback
                  ? 'CB ${prize!.value.toInt()}%'
                  : '-${prize!.value.toInt()}%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DiscountBadge extends StatelessWidget {
  final bool hasDiscount;
  final VoidCallback? onTap;

  const DiscountBadge({super.key, required this.hasDiscount, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (!hasDiscount) return const SizedBox.shrink();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_offer, color: Colors.white, size: 14),
            SizedBox(width: 6),
            Text(
              'HADIAH!',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
