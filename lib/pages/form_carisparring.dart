import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:uts_backend/helper/date_formatter.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:uts_backend/repository/venue_repository.dart';
import 'package:uts_backend/repository/user_repository.dart';
import 'package:uts_backend/model/cari_sparring_model.dart';
import 'package:uts_backend/model/venue_model.dart';
import 'package:uts_backend/model/user_model.dart';
import 'package:uts_backend/services/database_sqf.dart';

class FormCariSparring extends StatefulWidget {
  const FormCariSparring({super.key});

  @override
  State<FormCariSparring> createState() => _FormCariSparringState();
}

class _FormCariSparringState extends State<FormCariSparring> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namaTimController = TextEditingController();
  final TextEditingController _kotaController = TextEditingController();
  final TextEditingController _provinsiController = TextEditingController();
  final TextEditingController _minTimeController = TextEditingController();
  final TextEditingController _maxTimeController = TextEditingController();
  int? idUser;
  DateTime? _selectedDate;

  String namaVenue = '';
  List<UserModel> _userList = [];
  List<VenueModel> _venueList = [];
  String alert = '';
  final currentUser = FirebaseAuth.instance.currentUser;
  String? _selectedVenue;
  String? _selectedKategori;
  String? _selectedUserPartner;

  Future<int> getNextSparringId() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('sparrings')
        .orderBy('sparring_id', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return 1;
    }

    final lastId = snapshot.docs.first.data()['sparring_id'] ?? 0;
    return lastId + 1;
  }

  final List<String> _kategoriList = [
    'ganda wanita',
    'ganda pria',
    'ganda campuran',
    'tunggal pria',
    'tunggal wanita',
  ];

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (picked != null) {
      print('ini picked : ${picked}');
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _loadUsers() async {
    final users = await UserRepository.getAllUser();
    setState(() {
      _userList = users;
    });
  }

  Future<void> _loadVenues() async {
    final venues = await VenueRepository.get();
    setState(() {
      _venueList = venues;
    });
  }

  Future<void> _pickedTime(
    BuildContext context,
    TextEditingController control,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      print('ini picked time : ${picked}');
      setState(() {
        control.text =
            '${MaterialLocalizations.of(context).formatTimeOfDay(picked, alwaysUse24HourFormat: true)}';
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _loadUsers();
    _loadVenues();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final test = DatabaseSqf();
    final isKategoriGanda =
        _selectedKategori != null &&
        _selectedKategori!.toLowerCase().contains('ganda');

    return Scaffold(
      appBar: AppBar(title: const Text('Form Cari Sparring')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Venue',
                  border: OutlineInputBorder(),
                ),
                value: _selectedVenue,
                items: _venueList
                    .map<DropdownMenuItem<String>>(
                      (venue) => DropdownMenuItem<String>(
                        onTap: () {
                          setState(() {
                            namaVenue = venue.nama!;
                          });
                        },
                        value: venue.venueId.toString(),
                        child: Text(venue.nama.toString()),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedVenue = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Pilih venue terlebih dahulu' : null,
              ),

              const SizedBox(height: 12),
              TextFormField(
                controller: _namaTimController,
                decoration: const InputDecoration(
                  labelText: 'Nama Tim',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Nama tim tidak boleh kosong' : null,
              ),

              const SizedBox(height: 12),
              TextFormField(
                controller: _kotaController,
                decoration: const InputDecoration(
                  labelText: 'Kota',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Kota tidak boleh kosong' : null,
              ),

              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                value: _selectedKategori,
                validator: (value) =>
                    value == null ? 'Kategori tidak boleh kosong' : null,
                items: _kategoriList
                    .map(
                      (kategori) => DropdownMenuItem(
                        value: kategori,
                        child: Text(kategori),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedKategori = value;
                    _selectedUserPartner = null;
                  });
                },
              ),

              if (isKategoriGanda) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Partner (User)',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedUserPartner,
                  items: _userList
                      .where(
                        (u) => u.uid.toString() != currentUser!.uid.toString(),
                      )
                      .map<DropdownMenuItem<String>>(
                        (user) => DropdownMenuItem<String>(
                          value: user.uid.toString(),
                          child: Text(user.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedUserPartner = value;

                      print('ini value : ${value}');
                    });
                  },
                  validator: (value) => value == null
                      ? 'Pilih partner untuk kategori ganda'
                      : null,
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _provinsiController,
                decoration: const InputDecoration(
                  labelText: 'Provinsi',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Provinsi tidak boleh kosong' : null,
              ),

              const SizedBox(height: 12),
              TextFormField(
                controller: _minTimeController,

                onTap: () {
                  _pickedTime(context, _minTimeController);
                },
                decoration: const InputDecoration(
                  labelText: 'Minimum Available Time',
                  hintText: 'Contoh: 08:00',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty
                    ? 'Minimum Available Time tidak boleh kosong'
                    : null,
              ),

              const SizedBox(height: 12),
              TextFormField(
                controller: _maxTimeController,
                onTap: () {
                  _pickedTime(context, _maxTimeController);
                },
                decoration: const InputDecoration(
                  labelText: 'Maximum Available Time',
                  hintText: 'Contoh: 20:00',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty
                    ? 'Maximum Available Time tidak boleh kosong'
                    : null,
              ),

              const SizedBox(height: 12),
              ListTile(
                title: Text(
                  _selectedDate == null
                      ? 'Pilih Tanggal'
                      : 'Tanggal: ${DateFormatter.format("EEE, dd MMM yyyy", _selectedDate!)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDate(context),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text(alert.isEmpty ? '' : alert),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final formData = {
                      'venue_id': _selectedVenue,
                      'nama_tim': _namaTimController.text,
                      'kota': _kotaController.text,
                      'kategori': _selectedKategori,
                      'partner_user_id': _selectedUserPartner,
                      'provinsi': _provinsiController.text,
                      'min_time': _minTimeController.text,
                      'max_time': _maxTimeController.text,
                      'tanggal': _selectedDate?.toIso8601String(),
                    };
                    if (_selectedDate == null) {
                      setState(() {
                        alert = 'Tanggal tidak boleh kosong';
                      });
                    } else {
                      debugPrint('Data form: $formData');
                    }
                  }
                  if (_selectedDate == null) {
                    setState(() {
                      alert = 'Tanggal tidak boleh kosong';
                    });
                    return;
                  } else {
                    setState(() {
                      alert = '';
                    });
                  }
                  try {
                    final formattedDate =
                        "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";
                    final temp = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser!.uid)
                        .get();
                    final id = temp.data()?["user_id"];
                    final nama = temp.data()?["name"];
                    final List<Map<String, dynamic>> participants = [
                      {'userId': id, 'nama': '${nama}', 'role': 'penantang'},
                    ];

                    if (_selectedUserPartner != null) {
                      final temp2 = await FirebaseFirestore.instance
                          .collection('users')
                          .doc(_selectedUserPartner!)
                          .get();
                      final id2 = temp2.data()?["user_id"];
                      final nama2 = temp2.data()?["name"];
                      print('Ini nama :${nama2}');
                      participants.add({
                        'userId': id2,
                        'nama': '$nama2',
                        'role': 'penantang',
                      });
                    }
                    final sparid = await getNextSparringId();
                    final data = await FirebaseFirestore.instance
                        .collection('sparrings')
                        .add({
                          'sparring_id': sparid,
                          'venue_id': int.parse(_selectedVenue!),
                          'nama_tim': _namaTimController.text,
                          'kota': _kotaController.text,
                          'provinsi': _provinsiController.text,
                          'kategori': _selectedKategori,
                          'jam_mulai': _minTimeController.text,
                          'jam_selesai': _maxTimeController.text,
                          'tanggal': _selectedDate!.toUtc().toIso8601String(),
                          'status': 'open',
                          'participant': participants,
                        });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Form berhasil disubmit')),
                    );
                    print("id doc: ${data.id}");
                    test.insertCariSparring(
                      CariSparringModel(
                        uidspar: data.id,
                        uiduser1: currentUser!.uid,
                        uiduser2: _selectedUserPartner,
                        namaSparring: _namaTimController.text,
                        venue: namaVenue,
                        tanggal: formattedDate,
                        kategori: _selectedKategori!,
                      ),
                    );

                    Navigator.pop(context, true);
                  } catch (e) {
                    debugPrint('Error submit sparring: $e');
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
