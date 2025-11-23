import 'package:flutter/material.dart';
import 'package:uts_backend/database/database_service.dart';
import 'package:uts_backend/helper/homecachemanager.dart';
import 'package:uts_backend/pages/notification_screen.dart';
import 'package:uts_backend/pages/profil.dart';
import 'package:uts_backend/pages/venue_list_screen.dart';
import 'package:uts_backend/widgets/mabar_card.dart';
import 'package:uts_backend/widgets/quick_menu_item.dart';
import 'package:uts_backend/widgets/sparring_news_card.dart';
import 'package:uts_backend/widgets/schedule.dart';
import 'package:uts_backend/widgets/skeletons/sparring_news_card_skeleton.dart';
import 'package:uts_backend/widgets/skeletons/sparring_card_skeleton.dart';
import 'package:uts_backend/widgets/skeletons/venue_card_skeleton.dart';
import 'package:uts_backend/widgets/sparring_card.dart';
import 'package:uts_backend/widgets/venue_card.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:provider/provider.dart';  // Tambah buat Provider
import 'package:uts_backend/database/providers/theme_provider.dart';  // Adjust path kalau beda

class HomeScreen extends StatefulWidget {
  final int id;
  const HomeScreen({super.key, required this.id});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController searchInput = TextEditingController();
  int currentPage = 0;
  bool notif = false;
  bool _isRefreshing = false;
  final ApiService _apiService = ApiService();
  List<dynamic> _venues = [];
  List<dynamic> _sparrings = [];
  List<dynamic> _sparringNews = [];
  bool _isLoadingVenues = true;
  bool _isLoadingSparrings = true;
  bool _isLoadingSparringNews = true;
  final List<Map<String, dynamic>> _dummySparringNews = [
    {
      'tanggal': DateTime.now().subtract(const Duration(days: 1)).toString(),
      'maximum_available_time': '14:30:00',
      'kota': 'Jakarta',
      'player_a': 'John Doe, Mike Smith',
      'player_b': 'Jane Doe, Sarah Wilson',
      'skor_set1': '21-19',
      'skor_set2': '21-18',
      'skor_set3': null,
      'kategori': 'Ganda Putra',
    },
    {
      'tanggal': DateTime.now().subtract(const Duration(days: 2)).toString(),
      'maximum_available_time': '16:00:00',
      'kota': 'Bandung',
      'player_a': 'Ahmad Rizki',
      'player_b': 'Budi Santoso',
      'skor_set1': '21-15',
      'skor_set2': '19-21',
      'skor_set3': '21-17',
      'kategori': 'Tunggal Putra',
    },
  ];

  @override
  void initState() {
    _loadHomeData();
    super.initState();
  }

  Future<void> _loadHomeData() async {
    await getNotifData();
    await getVenuesData();
    await getSparringsData();
    await getSparringNewsData();
    
    print(' Home data loaded successfully!');
  }

  getNotifData() async {
    try {
      final result = await _apiService.getNotifications();
      notif = result['success'] == true && result['data'] != null && result['data'].isNotEmpty;
      setState(() {});
    } catch (e) {
      print('Error getting notifications: $e');
    }
  }

  getVenuesData() async {
    try {
      final venues = await SimpleCacheManager.getVenuesWithCache(_apiService);
      setState(() {
        _venues = venues;
        _isLoadingVenues = false;
      });
    } catch (e) {
      print('Error getting venues: $e');
      setState(() => _isLoadingVenues = false);
    }
  }

  getSparringsData() async {
    try {
      final sparrings = await SimpleCacheManager.getSparringsWithCache(_apiService);
      setState(() {
        _sparrings = sparrings;
        _isLoadingSparrings = false;
      });
    } catch (e) {
      print('Error getting sparrings: $e');
      setState(() => _isLoadingSparrings = false);
    }
  }

  getSparringNewsData() async {
    try {
      final news = await SimpleCacheManager.getSparringNewsWithCache(_apiService);
      
      if (news.isEmpty) {
        useDummySparringNews();
      } else {
        setState(() {
          _sparringNews = news;
          _isLoadingSparringNews = false;
        });
      }
    } catch (e) {
      print('Error getting sparring news: $e');
      useDummySparringNews();
    }
  }

  useDummySparringNews() {
    _sparringNews = _dummySparringNews;
    _isLoadingSparringNews = false;
    setState(() {});
  }

  Future<void> _onRefresh() async {
    if (_isRefreshing) return;
    
    print('🎯 _onRefresh DIPANGGIL!');
    
    setState(() {
      _isRefreshing = true;
      _isLoadingSparrings = true;
      _isLoadingSparringNews = true;
    });
    
    try {
      await Future.delayed(Duration(milliseconds: 800));
      
      final results = await SimpleCacheManager.forceRefreshAllData(_apiService);
      
      if (results['success'] == true) {
        setState(() {
          _venues = results['venues'] ?? [];
          _sparrings = results['sparrings'] ?? [];
          _sparringNews = results['sparringNews'] ?? [];
          _isLoadingVenues = false;
          _isLoadingSparrings = false;
          _isLoadingSparringNews = false;
          _isRefreshing = false;
        });
        
        if (_sparringNews.isEmpty) {
          useDummySparringNews();
        }
        
        print(' Pull to refresh completed successfully!');
        _showRefreshSuccess();
      } else {
        setState(() {
          _isRefreshing = false;
          _isLoadingVenues = false;
          _isLoadingSparrings = false;
          _isLoadingSparringNews = false;
        });
        _showRefreshError();
      }
      
    } catch (e) {
      print(' Pull to refresh error: $e');
      setState(() {
        _isRefreshing = false;
        _isLoadingVenues = false;
        _isLoadingSparrings = false;
        _isLoadingSparringNews = false;
      });
      _showRefreshError();
    }
  }

  void _showRefreshSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Data berhasil diperbarui', style: TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: Color.fromRGBO(21, 116, 42, 1),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showRefreshError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Gagal memperbarui data', style: TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final bool isDark = themeProvider.isDarkMode;

        Widget halamanProfil = Profil(id: widget.id);
        return Scaffold(
          backgroundColor: isDark ? Colors.black87 : Colors.white,
          body: currentPage != 0
              ? halamanProfil
              : RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: const Color.fromRGBO(21, 116, 42, 1),
                  backgroundColor: isDark ? Colors.grey[850] : Colors.white,
                  displacement: 40,
                  strokeWidth: 2.5,
                  child: _isRefreshing 
                      ? _buildFullSkeleton(isDark) 
                      : _buildHomeContent(isDark), 
                ),
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: isDark ? Colors.grey[900] : Colors.white,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
            ],
            currentIndex: currentPage,
            selectedItemColor: Colors.amber[800],
            unselectedItemColor: isDark ? Colors.white70 : Colors.grey[600],
            onTap: (value) {
              setState(() {
                currentPage = value;
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildHomeContent(bool isDark) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Stack(
        children: [
          Container(
            height: 140,
            decoration: const BoxDecoration(
              color: Color.fromRGBO(21, 116, 42, 1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(top: 8),
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: IconButton(
                            onPressed: () async {
                              bool result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const NotificationScreen(),
                                ),
                              );
                              if (result) {
                                setState(() {
                                  getNotifData();
                                });
                              }
                            },
                            icon: Stack(
                              children: [
                                const Icon(
                                  Icons.notifications_none,
                                  size: 26,
                                  color: Colors.white,
                                ),
                                notif
                                    ? Positioned(
                                        top: 1,
                                        right: 1,
                                        child: Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Halo, Kawan GORKITA!",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 28,
                          ),
                        ),
                        Card(
                          color: isDark ? Colors.grey[850] : Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 16,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search,
                                  color: Colors.grey[600],
                                  size: 28,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextField(
                                    controller: searchInput,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(0),
                                      hintText: "Cari GOR, Pengguna",
                                      hintStyle: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Schedule(isDark: isDark),  // Pass isDark ke Schedule

                        Card(
                          color: isDark ? Colors.grey[850] : Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    QuickMenuItem(
                                      icon: Icons.confirmation_number,
                                      name: "Booking",
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => const VenueListScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                    QuickMenuItem(
                                      icon: Icons.scoreboard_rounded,
                                      name: "Sparring",
                                      onTap: () {},
                                    ),
                                    QuickMenuItem(
                                      icon: Icons.groups,
                                      name: "Main Bareng",
                                      onTap: () {},
                                    ),
                                    QuickMenuItem(
                                      icon: Icons.handshake,
                                      name: "Komunitas",
                                      onTap: () {},
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              MabarCard(isDark: isDark),  // Pass isDark ke MabarCard
              const SizedBox(height: 18),
              _isLoadingVenues
                  ? _buildVenueSkeleton(isDark)
                  : _buildVenueSection(isDark),

              const SizedBox(height: 18),
              _isLoadingSparrings
                  ? _buildSparringSkeleton(isDark)
                  : _buildSparringSection(isDark),

              const SizedBox(height: 18),
              _buildSparringNewsSection(isDark),

              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFullSkeleton(bool isDark) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Stack(
        children: [
          Container(
            height: 140,
            decoration: const BoxDecoration(
              color: Color.fromRGBO(21, 116, 42, 1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderSkeleton(isDark),
              _buildMabarSkeleton(isDark),
              const SizedBox(height: 18),
              _buildVenueSkeleton(isDark),
              const SizedBox(height: 18),
              _buildSparringSkeleton(isDark),
              const SizedBox(height: 18),
              _buildSparringNewsSkeleton(isDark),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSkeleton(bool isDark) {
    return Skeletonizer(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 8),
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[700] : Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 250,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  color: isDark ? Colors.grey[850] : Colors.white,
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          color: isDark ? Colors.grey[700] : Colors.grey[300],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            height: 20,
                            color: isDark ? Colors.grey[700] : Colors.grey[300],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Schedule(isDark: isDark),  // Pass ke Schedule skeleton kalau ada
                Card(
                  color: isDark ? Colors.grey[850] : Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(4, (index) => 
                            Column(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.grey[700] : Colors.grey[300],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: 60,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.grey[700] : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMabarSkeleton(bool isDark) {
    return Skeletonizer(
      child: Card(
        color: isDark ? Colors.grey[850] : Colors.white,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 180,
                height: 20,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVenueSkeleton(bool isDark) {
    return Skeletonizer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Venue pilihan untukmu",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: null,
                  icon: const Icon(
                    Icons.arrow_circle_right_sharp,
                    color: Color.fromRGBO(21, 116, 42, 1),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 330,
            child: ListView.builder(
              itemBuilder: (context, index) => const VenueCardSkeleton(),
              itemCount: 4,
              scrollDirection: Axis.horizontal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Venue pilihan untukmu",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const VenueListScreen(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.arrow_circle_right_sharp,
                  color: Color.fromRGBO(21, 116, 42, 1),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: 330,
          child: ListView.builder(
            itemBuilder: (context, index) {
              final venue = _venues[index];
              return VenueCard(
                id: venue['venue_id'] ?? 0,
                url: venue['url'] ?? '',
                nama: venue['nama_venue'] ?? '',
                kota: venue['kota'] ?? '',
                harga: int.tryParse(venue['harga_perjam']?.toString() ?? '0') ?? 0,
                jumlahrating: venue['total_rating'] ?? 0,
                rating: (venue['rating'] ?? 0.0).toDouble(),
                isDark: isDark,  // Pass ke VenueCard
              );
            },
            itemCount: _venues.length,
            scrollDirection: Axis.horizontal,
          ),
        ),
      ],
    );
  }

  Widget _buildSparringSkeleton(bool isDark) {
    return Skeletonizer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Lagi cari lawan sparring",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                IconButton(
                  onPressed: null,
                  icon: const Icon(
                    Icons.arrow_circle_right_sharp,
                    color: Color.fromRGBO(21, 116, 42, 1),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 190,
            child: ListView.builder(
              itemBuilder: (context, index) => const SparringCardSkeleton(),
              itemCount: 4,
              scrollDirection: Axis.horizontal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSparringSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Lagi cari lawan sparring",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.arrow_circle_right_sharp,
                  color: Color.fromRGBO(21, 116, 42, 1),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: 200,
          child: ListView.builder(
            itemBuilder: (context, index) {
              final sparring = _sparrings[index];
              final searchPlayer = (sparring['search_player'] ?? '').split(", ");
              final String player1 = searchPlayer.isNotEmpty ? searchPlayer[0] : '';
              final String? player2 = searchPlayer.length > 1 ? searchPlayer[1] : null;
              
              return SparringCard(
                player1: player1,
                player2: player2,
                namaTim: sparring['nama_tim'] ?? '',
                tanggal: DateTime.parse(sparring['tanggal'] ?? DateTime.now().toString()),
                minimumAvailableTime: (sparring['minimum_available_time'] ?? '').substring(0, 5),
                maximumAvailableTime: (sparring['maximum_available_time'] ?? '').substring(0, 5),
                provinsi: sparring['provinsi'] ?? '',
                kota: sparring['kota'] ?? '',
                kategori: sparring['kategori'] ?? '',
                isDark: isDark,  // Pass ke SparringCard
              );
            },
            itemCount: _sparrings.length,
            scrollDirection: Axis.horizontal,
          ),
        ),
      ],
    );
  }

  Widget _buildSparringNewsSection(bool isDark) {
    if (_isLoadingSparringNews) {
      return _buildSparringNewsSkeleton(isDark);
    }
    if (_sparringNews.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hasil Pertandingan",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  "Update langsung dari lapangan!",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 150,
            alignment: Alignment.center,
            child: const Text(
              "Belum ada hasil pertandingan",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hasil Pertandingan",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                "Update langsung dari lapangan!",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 204,
          child: ListView.builder(
            itemBuilder: (context, index) {
              final news = _sparringNews[index];
              final playerA = (news['player_a'] ?? '').split(", ");
              final playerB = (news['player_b'] ?? '').split(", ");
              
              return SparringNewsCard(
                tanggal: DateTime.parse(news['tanggal'] ?? DateTime.now().toString()),
                jam: (news['maximum_available_time'] ?? '').substring(0, 5),
                kota: news['kota'] ?? '',
                player1A: playerA.isNotEmpty ? playerA[0] : '',
                player1B: playerA.length > 1 ? playerA[1] : null,
                player2A: playerB.isNotEmpty ? playerB[0] : '',
                player2B: playerB.length > 1 ? playerB[1] : null,
                skorSet1: news['skor_set1'] ?? '',
                skorSet2: news['skor_set2'],
                skorSet3: news['skor_set3'],
                kategori: news['kategori'] ?? '',
                isDark: isDark,  // Pass ke SparringNewsCard
              );
            },
            itemCount: _sparringNews.length,
            scrollDirection: Axis.horizontal,
          ),
        ),
      ],
    );
  }

  Widget _buildSparringNewsSkeleton(bool isDark) {
    return Skeletonizer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hasil Pertandingan",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Text(
                  "Update langsung dari lapangan!",
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 204,
            child: ListView.builder(
              itemBuilder: (context, index) => const SparringNewsCardSkeleton(),
              itemCount: 4,
              scrollDirection: Axis.horizontal,
            ),
          ),
        ],
      ),
    );
  }
}