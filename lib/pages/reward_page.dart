import 'package:flutter/material.dart';

import 'package:marquee/marquee.dart';
import '../widgets/reward_progress_widget.dart';
import '../database/services/reward_service.dart';
import '../database/services/admob_service.dart';

class RewardPage extends StatefulWidget {
  final int userId;

  const RewardPage({super.key, required this.userId});

  @override
  State<RewardPage> createState() => _RewardPageState();
}

class _RewardPageState extends State<RewardPage> {
  final RewardService _rewardService = RewardService();
  final AdMobService _adMobService = AdMobService();

  static const _primary = Color(0xFF1B5E20);
  static const _secondary = Color(0xFF4CAF50);
  static const _surface = Color(0xFFF1F8E9);
  static const _bg = Color(0xFFFAFAFA);

  @override
  void initState() {
    super.initState();
    _initAds();
  }

  Future<void> _initAds() async {
    await _adMobService.initialize();
    await _rewardService.initNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text(
          'Promo & Reward',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: _primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _hadiahRandom(),
            RewardProgressWidget(
              oderId: widget.userId.toString(),
              onDiscountEarned: () {},
            ),
            _caraKerja(),
            _faqInfo(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _hadiahRandom() {
    final prizes = [
      {'icon': '🎯', 'name': 'Diskon 15%'},
      {'icon': '💰', 'name': 'Cashback 10K'},
      {'icon': '🎁', 'name': 'Diskon 20%'},
      {'icon': '✨', 'name': 'Cashback 15K'},
      {'icon': '🌟', 'name': 'Diskon 25%'},
    ];
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: const BoxDecoration(
        color: _primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const Text(
            'Hadiah Random',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 80,
            child: Marquee(
              text: prizes.map((prize) => "  ${prize['icon']} ${prize['name']}  ").join('   '),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              scrollAxis: Axis.horizontal,
              crossAxisAlignment: CrossAxisAlignment.center,
              blankSpace: 60.0,
              velocity: 40.0,
              pauseAfterRound: Duration(seconds: 0),
              startPadding: 10.0,
              accelerationDuration: Duration(seconds: 1),
              accelerationCurve: Curves.linear,
              decelerationDuration: Duration(milliseconds: 500),
              decelerationCurve: Curves.easeOut,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Selesaikan 5 hari tantangan untuk dapatkan salah satunya!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withAlpha(200),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _caraKerja() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: _primary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Cara Kerja',
                  style: TextStyle(
                    color: _primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          _buildInfoCard(
            Icons.play_circle_outline,
            'Tonton 1 iklan per hari',
            'Kamu hanya bisa menonton 1 iklan setiap hari.',
          ),
          _buildInfoCard(
            Icons.calendar_today_outlined,
            'Lanjutkan selama 5 hari',
            'Tidak perlu berturut-turut, progress tersimpan.',
          ),
          _buildInfoCard(
            Icons.auto_awesome_outlined,
            'Dapatkan hadiah random',
            'Setelah 5 hari, kamu dapat salah satu dari 5 hadiah.',
          ),
          _buildInfoCard(
            Icons.shopping_bag_outlined,
            'Gunakan saat booking',
            'Hadiah otomatis tersedia saat checkout.',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _secondary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: _primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _faqInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Icon(Icons.help_outline, color: _secondary, size: 20),
                SizedBox(width: 8),
                Text(
                  'FAQ',
                  style: TextStyle(
                    color: _primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          _faqInfoCard(
            'Apa bedanya Diskon dan Cashback?',
            'Diskon langsung memotong harga. Cashback adalah uang kembali setelah transaksi selesai.',
          ),
          _faqInfoCard(
            'Harus 5 hari berturut-turut?',
            'Tidak. Kamu bisa nonton kapan saja, progress tersimpan.',
          ),
          _faqInfoCard(
            'Berapa lama hadiah berlaku?',
            'Hadiah berlaku sampai digunakan untuk 1x booking.',
          ),
          _faqInfoCard(
            'Bisa ikut lagi setelah pakai?',
            'Ya! Setelah hadiah dipakai, tantangan akan reset.',
          ),
        ],
      ),
    );
  }

  Widget _faqInfoCard(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _surface),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.help_outline, size: 16, color: _secondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  question,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: _primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text(
              answer,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
