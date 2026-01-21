
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uts_backend/model/cari_sparring_model.dart';
import 'package:uts_backend/pages/form_carisparring.dart';
import 'package:uts_backend/services/database_sqf.dart';

class SparringPage extends StatefulWidget {
  @override
  State<SparringPage> createState() => _SparringPageState();
}

class _SparringPageState extends State<SparringPage> {
  List<CariSparringModel>? dataSpar;
  String test = '';
  int? userId;
  DatabaseSqf db = DatabaseSqf();


  dataSparr() async {
    String tes = await FirebaseAuth.instance.currentUser!.uid;
    List<CariSparringModel> wel = await db.getSparringByIdUser(tes);
    if (wel.isNotEmpty) {
      setState(() {
        dataSpar = wel;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    dataSparr();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(21, 116, 42, 1),
        title: Text('Sparring Saya'),
       
        actions: [
          IconButton(
            onPressed: ()async {
              final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FormCariSparring()),
                );


                if (result == true) {
                  dataSparr();
                }
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
                    leading: Image.asset(
                      'assets/icons/shuttlecock.png',
                      width: 30,
                      color: Colors.blueAccent,
                    ),

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