import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uts_backend/model/cari_sparring_model.dart';
import 'package:uts_backend/pages/form_carisparring.dart';

class FavoritPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorit Saya'),
        backgroundColor: Color.fromRGBO(21, 116, 42, 1),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite,
              size: 64,
              color: Color.fromRGBO(21, 116, 42, 1),
            ),
            SizedBox(height: 16),
            Text(
              'Halaman Favorit',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Daftar item favorit Anda akan muncul di sini',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class LikePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Like Saya'),
        backgroundColor: Color(0xFF2196F3),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.thumb_up,
              size: 64,
              color: Color.fromRGBO(21, 116, 42, 1),
            ),
            SizedBox(height: 16),
            Text(
              'Halaman Like',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Daftar item yang Anda like akan muncul di sini',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class BookingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Saya'),
        backgroundColor: Color(0xFF4CAF50),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 64,
              color: Color.fromRGBO(21, 116, 42, 1),
            ),
            SizedBox(height: 16),
            Text(
              'Halaman Booking',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Daftar booking Anda akan muncul di sini',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class SparringPage extends StatefulWidget {
  @override
  State<SparringPage> createState() => _SparringPageState();
}

class _SparringPageState extends State<SparringPage> {
  List<CariSparringModel>? dataSpar;
  String test = '';
  int? userId;
  initPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    userId = prefs.getInt('id');
    // Firebase-only: Remove local database calls
    // Load data from Firestore instead if needed
  }

  @override
  void initState() {
    super.initState();
    initPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sparring Saya'),
        backgroundColor: Color(0xFFFF9800),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FormCariSparring()),
              ).then((_) {
                initPrefs();
              });
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: dataSpar != null
          ? ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: dataSpar!.length,
              itemBuilder: (context, index) {
                final sparring = dataSpar![index];

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: Image.asset('assets/icons/shuttlecock.png',width: 30,color: Colors.blueAccent,),
                  
                    title: Text(
                      sparring.namaSparring,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Tanggal: ${sparring.tanggal}"),
                        Text("Venue: ${sparring.venue}"),
                        Text("Kategori: ${sparring.kategori}"),
                      ],
                    ),
                  ),
                );
              },
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sports_martial_arts,
                    size: 64,
                    color: Color.fromRGBO(21, 116, 42, 1),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Halaman Sparring',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Daftar sesi sparring Anda akan muncul di sini',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
    );
  }
}

class MabarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mabar Saya'),
        backgroundColor: Color.fromRGBO(21, 116, 42, 1),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group, size: 64, color: Color.fromRGBO(21, 116, 42, 1)),
            SizedBox(height: 16),
            Text(
              'Halaman Mabar',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Daftar sesi mabar Anda akan muncul di sini',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

class RiwayatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Saya'),
        backgroundColor: Color(0xFF607D8B),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Color.fromRGBO(21, 116, 42, 1),
            ),
            SizedBox(height: 16),
            Text(
              'Halaman Riwayat',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Riwayat aktivitas Anda akan muncul di sini',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
