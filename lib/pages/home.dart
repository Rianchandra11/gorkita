import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:uts_backend/database/database_service.dart';
import 'package:uts_backend/model/venue_model.dart';
import 'package:uts_backend/pages/profil.dart';
import 'package:uts_backend/pages/venue_list_screen.dart';
import 'package:uts_backend/pages/venue_location_screen.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:uts_backend/model/sparring_model.dart';
import 'package:uts_backend/repository/sparring_repository.dart';
import 'package:uts_backend/repository/venue_repository.dart';
import 'package:uts_backend/widgets/mabar_card.dart';
import 'package:uts_backend/widgets/notification_button.dart';
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
import 'package:permission_handler/permission_handler.dart';

import 'dart:async';

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
  final ApiService _apiService = ApiService();
  List<VenueModel> _venueLocation = [];
  bool locationGranted = false;
  String apaaja = '';
  StreamSubscription<geo.ServiceStatus>? _serviceStatusStreamSubscription;

  List<dynamic> venuesLocation = [];
  Widget _buildVenuePermissionLocation(bool isDark) {
    return Column(
      children: [
        Center(child: Icon(Icons.location_off)),
        SizedBox(
          width: 200,
          height: 50,
          child: Text(
            'Butuh akses lokasi untuk mencari venue terdekat di kota kamu !',
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            getLocationUser();
          },
          
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? Colors.grey[850] : Colors.white54,
            foregroundColor: isDark ? Colors.white : Colors.black87,
            shadowColor: isDark ? Colors.black26 : Colors.white,
          ),
          child: Text('Aktifkan'),
        ),
      ],
    );
  }

  Widget _buildVenueDisplayLocation(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Venue untukmu di ${apaaja}",
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
                      builder: (context) =>
                          VenueLocationScreen(venueLoc: _venueLocation),
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
              final venue = _venueLocation[index];
              return VenueCard(
                id: venue.venueId!,
                url: venue.linkGambar![0],
                nama: venue.nama!,
                kota: venue.kota!,
                harga: venue.harga!,
                jumlahrating: venue.totalRating!,
                rating: venue.rating!,
                isDark: isDark, // Pass ke VenueCard
              );
            },
            itemCount: _venueLocation.length,
            scrollDirection: Axis.horizontal,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    // Sangat penting untuk membatalkan subscription agar tidak memory leak
    _serviceStatusStreamSubscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        // This is just a basic example. For real apps, you must show some
        // friendly dialog box before call the request method.
        // This is very important to not harm the user experience
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    ;
    _listenToGpsStatus();
    super.initState();
  }

  Future<void> locationNotification() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
        channelKey: 'location_active',
        actionType: ActionType.Default,
        title: 'Akses Lokasi Sedang Aktif',
        body: 'Akses Lokasi sedang diaktifkan',
        autoDismissible: false,
        locked: true,
      ),
    );
  }

  void _listenToGpsStatus() async {
    
    _serviceStatusStreamSubscription = geo.Geolocator.getServiceStatusStream()
        .listen((geo.ServiceStatus status) async{
          
          if (status == geo.ServiceStatus.enabled) {
          
            print("GPS Aktif");
            
          } else {
            print("GPS Mati");
            AwesomeNotifications().cancel(10);
            setState(() {
              locationGranted = false;
              _venueLocation = [];
            });
          }
        });
  }

  Future<void> getGorLocation(double lat, double lon) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
    Placemark place = placemarks[0];
    String namaKota = place.subAdministrativeArea!
        .split(' ')
        .getRange(1, place.subAdministrativeArea!.split(' ').length)
        .join(' ');

    final venueasli = await VenueRepository.get();
    setState(() {
      locationGranted = true;

      _venueLocation = venueasli.where((e) => e.kota == namaKota).toList();
      print(_venueLocation);
      apaaja = namaKota;
    });
  }

  getLocationUser() async {
    var status = await Permission.location.status;
    if (status.isDenied) {
      Permission.location.request();
    } else if (status.isGranted) {
      var loc = await geo.Geolocator.getCurrentPosition();

      getGorLocation(loc.latitude, loc.longitude);
      locationNotification();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

 
  getNotifData() async {
    try {
      final result = await _apiService.getNotifications();
      notif =
          result['success'] == true &&
          result['data'] != null &&
          result['data'].isNotEmpty;
      setState(() {});
    } catch (e) {
      print('Error getting notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final bool isDark = themeProvider.isDarkMode;

        Widget halamanProfil = Profil(id: widget.id);
        return Scaffold(
          backgroundColor: isDark ? Colors.black87 : Colors.white,
          body: currentPage != 0 ? halamanProfil : _buildHomeContent(isDark),
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
                        children: [NotificationButton()],
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

                          Schedule(isDark: isDark, userId: 22),

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
                                              builder: (BuildContext context) =>
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
                    return _buildVenueSection(
                      context,
                      isDark,
                      asyncSnapshot.data!,
                    );
                  },
                ),
                const SizedBox(height: 18),
                locationGranted
                    ? _buildVenueDisplayLocation(isDark)
                    : _buildVenuePermissionLocation(isDark),
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

Widget _buildClosedSparringSection(bool isDark, List<SparringModel> snapshot) {
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

Widget _buildVenueSection(
  BuildContext context,
  bool isDark,
  List<VenueModel> data,
) {
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
