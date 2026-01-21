import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uts_backend/i10n/countries.dart';

class CountryService {
  static final CountryService _instance = CountryService._internal();
  factory CountryService() => _instance;
  CountryService._internal();

  late final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Simpan negara pilihan ke Firestore
  /// Mengembalikan pesan error jika update tidak diizinkan (dalam 1 jam), null jika berhasil
  Future<String?> simpanNegaraPilihan(String idPengguna, Country negara) async {
    try {
      final refPengguna = _firestore.collection('users').doc(idPengguna);
      final dokPengguna = await refPengguna.get();

      if (!dokPengguna.exists) {
        return 'Pengguna tidak ditemukan';
      }

      final dataPengguna = dokPengguna.data() ?? {};
      final updateNegaraTerakhir = dataPengguna['updateNegaraTerakhir'] as Timestamp?;
      final sekarang = DateTime.now();

      // Periksa apakah 1 jam telah berlalu sejak update terakhir
      if (updateNegaraTerakhir != null) {
        final waktuUpdateTerakhir = updateNegaraTerakhir.toDate();
        final perbedaan = sekarang.difference(waktuUpdateTerakhir);

        if (perbedaan.inHours < 1) {
          final menitTersisa = 60 - perbedaan.inMinutes;
          return 'Tidak bisa update negara. Silahkan tunggu $menitTersisa menit sebelum update lagi.';
        }
      }

      // Update data negara
      await refPengguna.update({
        'kodeNegara': negara.kode,
        'namaNegara': negara.nama,
        'kodeDial': negara.kodeDial,
        'updateNegaraTerakhir': FieldValue.serverTimestamp(),
        'diupdate': FieldValue.serverTimestamp(),
      });

      return null; 
    } catch (e) {
      return 'Error menyimpan negara: $e';
    }
  }

  /// Ambil negara pilihan pengguna dari Firestore
  Future<Country?> ambilNegaraPilihan(String idPengguna) async {
    try {
      final dokPengguna = await _firestore.collection('users').doc(idPengguna).get();

      if (!dokPengguna.exists) {
        return null;
      }

      final dataPengguna = dokPengguna.data() ?? {};
      final kode = dataPengguna['kodeNegara'] as String?;

      if (kode == null) {
        return null;
      }

      return cariNegaraBerdasarkanKode(kode);
    } catch (e) {
      print('Error mengambil negara pilihan: $e');
      return null;
    }
  }

  /// Periksa apakah pengguna bisa update negara (1 jam berlalu)
  Future<Map<String, dynamic>> bisaUpdateNegara(String idPengguna) async {
    try {
      final dokPengguna = await _firestore.collection('users').doc(idPengguna).get();

      if (!dokPengguna.exists) {
        return {'bisaUpdate': true, 'menitTersisa': 0};
      }

      final dataPengguna = dokPengguna.data() ?? {};
      final updateNegaraTerakhir = dataPengguna['updateNegaraTerakhir'] as Timestamp?;

      if (updateNegaraTerakhir == null) {
        return {'bisaUpdate': true, 'menitTersisa': 0};
      }

      final sekarang = DateTime.now();
      final waktuUpdateTerakhir = updateNegaraTerakhir.toDate();
      final perbedaan = sekarang.difference(waktuUpdateTerakhir);

      if (perbedaan.inHours >= 1) {
        return {'bisaUpdate': true, 'menitTersisa': 0};
      }

      final menitTersisa = 60 - perbedaan.inMinutes;
      return {'bisaUpdate': false, 'menitTersisa': menitTersisa};
    } catch (e) {
      print('Error memeriksa status update: $e');
      return {'bisaUpdate': true, 'menitTersisa': 0};
    }
  }

  /// Ambil waktu update negara terakhir
  Future<DateTime?> ambilWaktuUpdateNegaraTerakhir(String idPengguna) async {
    try {
      final dokPengguna = await _firestore.collection('users').doc(idPengguna).get();

      if (!dokPengguna.exists) {
        return null;
      }

      final dataPengguna = dokPengguna.data() ?? {};
      final updateNegaraTerakhir = dataPengguna['updateNegaraTerakhir'] as Timestamp?;

      return updateNegaraTerakhir?.toDate();
    } catch (e) {
      print('Error mengambil waktu update terakhir: $e');
      return null;
    }
  }
}
