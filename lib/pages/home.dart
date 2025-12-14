import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:uts_backend/model/sparring_model.dart';
import 'package:uts_backend/model/venue_model.dart';
import 'package:uts_backend/pages/notification_screen.dart';
import 'package:uts_backend/pages/profil.dart';
import 'package:uts_backend/pages/venue_list_screen.dart';
import 'package:uts_backend/repository/sparring_repository.dart';
import 'package:uts_backend/repository/venue_repository.dart';
import 'package:uts_backend/widgets/mabar_card.dart';
import 'package:uts_backend/widgets/quick_menu_item.dart';
import 'package:uts_backend/widgets/skeletons/sparring_card_skeleton.dart';
import 'package:uts_backend/widgets/skeletons/sparring_news_card_skeleton.dart';
import 'package:uts_backend/widgets/skeletons/venue_card_skeleton.dart';
import 'package:uts_backend/widgets/sparring_news_card.dart';
import 'package:uts_backend/widgets/schedule.dart';
import 'package:uts_backend/widgets/sparring_card.dart';
import 'package:uts_backend/widgets/venue_card.dart';
import 'package:provider/provider.dart';
import 'package:uts_backend/database/providers/theme_provider.dart';

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

  // --- DATA DUMMY (Langsung diinisialisasi) ---
  final List<Map<String, dynamic>> _venues = [
    {
      'venue_id': 1,
      'url': 'https://placehold.co/600x400/png',
      'nama_venue': 'GOR Cendrawasih',
      'kota': 'Jakarta Barat',
      'harga_perjam': 50000,
      'total_rating': 120,
      'rating': 4.5,
    },
    {
      'venue_id': 2,
      'url': 'https://placehold.co/600x400/png',
      'nama_venue': 'Arena Badminton Jaya',
      'kota': 'Jakarta Selatan',
      'harga_perjam': 75000,
      'total_rating': 85,
      'rating': 4.8,
    },
    {
      'venue_id': 3,
      'url': 'https://placehold.co/600x400/png',
      'nama_venue': 'Hall Sport Center',
      'kota': 'Bandung',
      'harga_perjam': 60000,
      'total_rating': 200,
      'rating': 4.2,
    },
  ];

  final List<Map<String, dynamic>> _sparrings = [
    {
      'search_player': 'Budi Santoso, Ahmad',
      'nama_tim': 'Tim Rajawali',
      'tanggal': DateTime.now().add(const Duration(days: 2)).toString(),
      'minimum_available_time': '18:00:00',
      'maximum_available_time': '21:00:00',
      'provinsi': 'DKI Jakarta',
      'kota': 'Jakarta Timur',
      'kategori': 'Ganda Putra',
    },
    {
      'search_player': 'Siti Nurhaliza',
      'nama_tim': 'PB Djarum Kw',
      'tanggal': DateTime.now().add(const Duration(days: 3)).toString(),
      'minimum_available_time': '10:00:00',
      'maximum_available_time': '12:00:00',
      'provinsi': 'Jawa Barat',
      'kota': 'Depok',
      'kategori': 'Tunggal Putri',
    },
  ];

  final List<Map<String, dynamic>> _sparringNews = [
    {
      'tanggal': DateTime.now().subtract(const Duration(days: 1)).toString(),
      'maximum_available_time': '14:30:00',
      'kota': 'Jakarta',
      'player_a': 'John Doe, Mike Smith',
      'player_b': 'Jane Doe, Sarah Wilson',
      'skor_set1': '21-19',
      'skor_set2': '21-18',
      'skor_set3': null,
      'kategori': 'Ganda Campuran',
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
    super.initState();
    // Set notifikasi aktif secara default untuk dummy
    notif = true;
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
              : _buildHomeContent(isDark), // Langsung render konten
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: isDark ? Colors.grey[900] : Colors.white,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profil',
              ),
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
            height: 150,
            decoration: const BoxDecoration(
              color: Color.fromRGBO(21, 116, 42, 1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 18),
            child: Column(
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
                                bool? result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const NotificationScreen(),
                                  ),
                                );
                                if (result == true) {
                                  setState(() {
                                    notif = false;
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
                                              borderRadius:
                                                  BorderRadius.circular(5),
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
                                        contentPadding: const EdgeInsets.all(0),
                                        hintText: "Cari GOR, Pengguna",
                                        hintStyle: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                        border: const OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Schedule(isDark: isDark),

                          Card(
                            color: isDark ? Colors.grey[850] : Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      QuickMenuItem(
                                        icon: Icons.confirmation_number,
                                        name: "Booking",
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const VenueListScreen(),
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
                MabarCard(isDark: isDark),
                const SizedBox(height: 18),

                // --- VENUE SECTION ---
                FutureBuilder(
                  future: VenueRepository.get(),
                  builder: (context, asyncSnapshot) {
                    if (asyncSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return _buildVenueSkeleton(isDark);
                    }
                    return _buildVenueSection(isDark, asyncSnapshot.data!);
                  },
                ),

                const SizedBox(height: 18),

                // --- SPARRING SECTION ---
                FutureBuilder(
                  future: SparringRepository.getOpenMatches(),
                  builder: (context, asyncSnapshot) {
                    if (asyncSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return _buildOpenSparringSkeleton(isDark);
                    }
                    return _buildOpenSparringSection(
                      isDark,
                      asyncSnapshot.data!,
                    );
                  },
                ),

                const SizedBox(height: 18),

                // --- NEWS SECTION ---
                FutureBuilder(
                  future: SparringRepository.getClosedMatches(),
                  builder: (context, asyncSnapshot) {
                    if (asyncSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return _buildClosedSparringSkeleton(isDark);
                    }
                    return _buildClosedSparringSection(
                      isDark,
                      asyncSnapshot.data!,
                    );
                  },
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueSection(bool isDark, List<VenueModel> data) {
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
              return VenueCard(
                id: data[index].venueId!,
                url: data[index].linkGambar![0],
                nama: data[index].nama!,
                kota: data[index].kota!,
                harga: data[index].harga!,
                jumlahrating: data[index].totalRating!,
                rating: data[index].rating!,
                isDark: isDark,
              );
            },
            itemCount: data.length,
            scrollDirection: Axis.horizontal,
          ),
        ),
      ],
    );
  }

  Widget _buildOpenSparringSection(bool isDark, List<SparringModel> snapshot) {
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
              final data = snapshot[index];
              final String player1 = data.participant![0].nama!;
              final String? player2 = data.participant!.length > 1
                  ? data.participant![1].nama
                  : null;

              return SparringCard(
                player1: player1,
                player2: player2,
                namaTim: data.namaTim!,
                tanggal: data.tanggal!,
                minimumAvailableTime: data.jamMulai!,
                maximumAvailableTime: data.jamSelesai!,
                provinsi: data.provinsi!,
                kota: data.kota!,
                kategori: data.kategori!,
                isDark: isDark,
              );
            },
            itemCount: snapshot.length,
            scrollDirection: Axis.horizontal,
          ),
        ),
      ],
    );
  }

  Widget _buildClosedSparringSection(
    bool isDark,
    List<SparringModel> snapshot,
  ) {
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
              const Text(
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
              final data = snapshot[index];

              final timPenantang = data.participant!
                  .where((e) => e.role == "penantang")
                  .toList();
              final timPenerima = data.participant!
                  .where((e) => e.role == "penerima")
                  .toList();

              return SparringNewsCard(
                tanggal: data.tanggal!,
                jam: data.jamSelesai!,
                kota: data.kota!,
                player1A: timPenantang[0].nama!,
                player1B: timPenantang.length > 1 ? timPenantang[1].nama : null,
                player2A: timPenerima[0].nama!,
                player2B: timPenerima.length > 1 ? timPenerima[1].nama : null,
                kategori: data.kategori!,
                skorPenantang: data.score!.penantang!,
                skorPenerima: data.score!.penerima!,
                isDark: isDark,
              );
            },
            itemCount: snapshot.length,
            scrollDirection: Axis.horizontal,
          ),
        ),
      ],
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
                Skeleton.keep(
                  child: Text(
                    "Venue pilihan untukmu",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                Skeleton.ignore(
                  child: IconButton(
                    onPressed: null,
                    icon: const Icon(
                      Icons.arrow_circle_right_sharp,
                      color: Color.fromRGBO(21, 116, 42, 1),
                    ),
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

  Widget _buildOpenSparringSkeleton(bool isDark) {
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

  Widget _buildClosedSparringSkeleton(bool isDark) {
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
