import 'package:flutter/material.dart';
import 'package:uts_backend/model/user_coupon.dart';
import 'package:uts_backend/services/coupon_service.dart';
import 'package:uts_backend/services/reward_service.dart';

/// Halaman untuk melihat semua kupon yang dimiliki user
class KuponSayaPage extends StatefulWidget {
  final String userId;

  const KuponSayaPage({super.key, required this.userId});

  @override
  State<KuponSayaPage> createState() => _KuponSayaPageState();
}

class _KuponSayaPageState extends State<KuponSayaPage>
    with SingleTickerProviderStateMixin {
  final KuponService _KuponService = KuponService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _KuponService.ensureWelcomeCoupon(widget.userId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kupon Saya'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.green,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.green,
          tabs: const [
            Tab(text: 'Tersedia'),
            Tab(text: 'Riwayat'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAvailableCoupons(),
          _buildUsedCoupons(),
        ],
      ),
    );
  }

  Widget _buildAvailableCoupons() {
    return StreamBuilder<List<UserCoupon>>(
      stream: _KuponService.getAvailableCoupons(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final coupons = snapshot.data ?? [];

        if (coupons.isEmpty) {
          return _buildEmptyState(
            icon: Icons.local_offer_outlined,
            title: 'Belum Ada Kupon',
            subtitle:
                'Ikuti tantangan 5 hari di halaman Reward\nuntuk mendapatkan kupon!',
            showButton: true,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: coupons.length,
          itemBuilder: (context, index) => _buildCouponCard(coupons[index]),
        );
      },
    );
  }

  /// Tab riwayat kupon yang sudah digunakan
  Widget _buildUsedCoupons() {
    return StreamBuilder<List<UserCoupon>>(
      stream: _KuponService.getUsedCoupons(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final coupons = snapshot.data ?? [];

        if (coupons.isEmpty) {
          return _buildEmptyState(
            icon: Icons.history,
            title: 'Belum Ada Riwayat',
            subtitle: 'Kupon yang sudah digunakan akan muncul di sini.',
            showButton: false,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: coupons.length,
          itemBuilder: (context, index) =>
              _buildCouponCard(coupons[index], isUsed: true),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool showButton,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600),
          ),
          if (showButton) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to reward page
              },
              icon: const Icon(Icons.card_giftcard),
              label: const Text('Ikuti Tantangan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCouponCard(UserCoupon coupon, {bool isUsed = false}) {
    final prize = coupon.prize;
    // More reliable: check both type and name
    final isCashback = prize.type == RewardType.cashback || prize.name.toLowerCase().contains('cashback');
    final isDiscount = prize.type == RewardType.discount || prize.name.toLowerCase().contains('diskon');
    final baseColor = isCashback ? Colors.purple : Colors.green;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(18),
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: isUsed
                  ? [Colors.grey.shade200, Colors.grey.shade100]
                  : [baseColor.shade50, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: isUsed ? Colors.grey.shade300 : baseColor.shade200,
              width: 1.2,
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon & Value
                Container(
                  width: 90,
                  decoration: BoxDecoration(
                    color: isUsed ? Colors.grey.shade300 : baseColor.shade100,
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        prize.icon,
                        style: const TextStyle(fontSize: 36),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${prize.value.toInt()}%',
                        style: TextStyle(
                          color: isUsed ? Colors.grey.shade600 : baseColor.shade700,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isDiscount ? 'DISKON' : 'CASHBACK',
                        style: TextStyle(
                          color: isUsed ? Colors.grey.shade500 : (isCashback ? Colors.purple.shade700 : Colors.green.shade700),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                // Details
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                prize.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isUsed ? Colors.grey : Colors.black,
                                ),
                              ),
                            ),
                            if (isUsed)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'TERPAKAI',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          prize.description,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isUsed
                                  ? 'Digunakan: ${_formatDate(coupon.usedAt)}'
                                  : 'Didapat: ${_formatDate(coupon.createdAt)}',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        if (!isUsed) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => _showCouponDetail(coupon),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: baseColor,
                                side: BorderSide(color: baseColor),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Gunakan',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showCouponDetail(UserCoupon coupon) {
    final prize = coupon.prize;
    final isDiscount = prize.type == RewardType.discount;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                prize.icon,
                style: const TextStyle(fontSize: 60),
              ),
              const SizedBox(height: 16),
              Text(
                prize.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isDiscount ? Colors.green.shade50 : Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  prize.description,
                  style: TextStyle(
                    color: isDiscount ? Colors.green.shade700 : Colors.purple.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Kode Kupon', coupon.couponCode),
                    const Divider(),
                    _buildDetailRow('Tipe', isDiscount ? 'Diskon' : 'Cashback'),
                    const Divider(),
                    _buildDetailRow('Nilai', '${prize.value.toInt()}%'),
                    const Divider(),
                    _buildDetailRow(
                      'Berlaku Untuk',
                      'Semua Booking',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Kupon akan otomatis tersedia saat checkout booking',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDiscount ? Colors.green : Colors.purple,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Mengerti',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
