import 'package:flutter/material.dart';
import 'package:country_flags/country_flags.dart';
import 'package:uts_backend/i10n/countries.dart';

class CountryPhonePicker extends StatefulWidget {
  final Function(Country) onNegaraBerubah;
  final Country? negaraTerpilih;

  const CountryPhonePicker({
    super.key,
    required this.onNegaraBerubah,
    this.negaraTerpilih,
  });

  @override
  State<CountryPhonePicker> createState() => _CountryPhonePickerState();
}

class _CountryPhonePickerState extends State<CountryPhonePicker> {
  late Country negaraTerpilih;

  @override
  void initState() {
    super.initState();
    negaraTerpilih = widget.negaraTerpilih ?? countries[0]; // Default: Indonesia
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Negara',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        // Tombol Pilihan Negara
        GestureDetector(
          onTap: () => _tampilkanPemilikNegara(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  height: 24,
                  child: CountryFlag.fromCountryCode(
                    negaraTerpilih.kode,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        negaraTerpilih.nama,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        negaraTerpilih.kodeDial,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _tampilkanPemilikNegara(BuildContext context) {
    TextEditingController kontrolerPencarian = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final tersaring = cariNegara(kontrolerPencarian.text);
          return AlertDialog(
            title: const Text('Pilih Negara'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Kolom pencarian
                  TextField(
                    controller: kontrolerPencarian,
                    decoration: InputDecoration(
                      hintText: 'Cari negara...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  // Daftar negara
                  Expanded(
                    child: tersaring.isEmpty
                        ? const Center(
                            child: Text('Tidak ada negara yang ditemukan'),
                          )
                        : ListView.builder(
                            itemCount: tersaring.length,
                            itemBuilder: (context, indeks) {
                              final negara = tersaring[indeks];
                              return ListTile(
                                leading: SizedBox(
                                  width: 32,
                                  height: 24,
                                  child: CountryFlag.fromCountryCode(
                                    negara.kode,
                                  ),
                                ),
                                title: Text(negara.nama),
                                subtitle: Text(negara.kodeDial),
                                onTap: () => _pilihNegara(negara, context),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pilihNegara(Country negara, BuildContext context) async {
    setState(() {
      negaraTerpilih = negara;
    });
    widget.onNegaraBerubah(negara);
    Navigator.pop(context);
  }
}

// Widget input nomor telepon sederhana dengan kode negara
class InputNomorTelepon extends StatefulWidget {
  final Function(String) onNomorBerubah;
  final Country? negaraTerpilih;

  const InputNomorTelepon({
    super.key,
    required this.onNomorBerubah,
    this.negaraTerpilih,
  });

  @override
  State<InputNomorTelepon> createState() => _InputNomorTeleponState();
}

class _InputNomorTeleponState extends State<InputNomorTelepon> {
  late TextEditingController kontrolerTelepon;
  late Country negaraTerpilih;

  @override
  void initState() {
    super.initState();
    kontrolerTelepon = TextEditingController();
    negaraTerpilih = widget.negaraTerpilih ?? countries[0];
  }

  @override
  void dispose() {
    kontrolerTelepon.dispose();
    super.dispose();
  }

  String ambilNomorTeleponLengkap() {
    return '${negaraTerpilih.kodeDial}${kontrolerTelepon.text}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CountryPhonePicker(
          negaraTerpilih: negaraTerpilih,
          onNegaraBerubah: (negara) {
            setState(() {
              negaraTerpilih = negara;
            });
          },
        ),
        const SizedBox(height: 16),
        Text(
          'Nomor Telepon',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: kontrolerTelepon,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: 'Masukkan nomor telepon',
            prefixIcon: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.phone),
                  const SizedBox(width: 6),
                  Text(
                    negaraTerpilih.kodeDial,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          onChanged: (value) {
            widget.onNomorBerubah(ambilNomorTeleponLengkap());
          },
        ),
        const SizedBox(height: 8),
        Text(
          'Nomor lengkap: ${ambilNomorTeleponLengkap()}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
