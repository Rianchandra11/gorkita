import 'package:flutter/material.dart';

import 'package:uts_backend/helper/date_formatter.dart';
import 'package:uts_backend/helper/base_url.dart';
import 'package:http/http.dart' as http;
import 'package:uts_backend/database/sqflite/database_sqf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uts_backend/helper/homecachemanager.dart';
import 'package:uts_backend/model/cari_sparring_model.dart';

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
  SimpleCacheManager cache = SimpleCacheManager();
  String namaVenue = '';
  List<dynamic> _userList = [];
  List<dynamic> _venueList = [];
  String url = BaseUrl.url;
  String alert = '';

  String? _selectedVenue;
  String? _selectedKategori;
  String? _selectedUserPartner;

  getAlluser() async {
    try {
      var response = await http.get(Uri.parse('$url/getall/user'));
      var data = jsonDecode(response.body)["data"];
      setState(() {
        _userList = data;
      });
    } catch (e) {
      print(e);
    }
  }

  getAllVenue() async {
    try {
      var response = await http.get(Uri.parse('$url/display/venue'));
      var data = jsonDecode(response.body)["data"];
      setState(() {
        _venueList = data;
      });
    } catch (e) {
      print(e);
    }
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

  initPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      idUser = prefs.getInt('id');
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    getAlluser();
    getAllVenue();
    initPrefs();
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
                            namaVenue = venue['nama_venue'];
                          });
                        },
                        value: venue['venue_id'].toString(),
                        child: Text(venue['nama_venue'].toString()),
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
                      .map<DropdownMenuItem<String>>(
                        (user) => DropdownMenuItem<String>(
                          value: user['user_id'].toString(),
                          child: Text(user['name'].toString()),
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
                      try {
                        final formattedDate =
                            "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";
                        print('formated: ${formattedDate}');
                        final response = await http.post(
                          Uri.parse('$url/add/sparring'),
                          body: {
                            'venue_id': _selectedVenue,
                            'nama_tim': _namaTimController.text,
                            'kota': _kotaController.text,
                            'kategori': _selectedKategori,
                            'user': idUser.toString(),
                            'user2': _selectedUserPartner ?? '',
                            'provinsi': _provinsiController.text,
                            'minimum_available_time': _minTimeController.text,
                            'maximum_available_time': _maxTimeController.text,
                            'tanggal': formattedDate,
                          },
                        );
                        if (response.statusCode == 200) {
                          var coba = await test.insertCariSparring(
                            CariSparringModel(
                              idUser: idUser!.toInt(),
                              namaSparring: _namaTimController.text,
                              venue: namaVenue,
                              tanggal: formattedDate,
                              kategori: _selectedKategori!,
                            ),
                          );
                          print('testttt');
                          print(coba);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Form disubmit!')),
                          );

                          SimpleCacheManager.clearCache();
                          Navigator.pop(context, true);
                        }
                      } catch (e) {
                        print(e);
                      }
                      setState(() {
                        alert = '';
                      });
                    }
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
