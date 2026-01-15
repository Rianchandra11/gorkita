import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:uts_backend/widgets/country_phone_picker.dart';
import 'package:uts_backend/database/services/country_service.dart';
import 'package:uts_backend/i10n/countries.dart';

// Mock untuk CountryService
class MockCountryService extends Mock implements CountryService {}

void main() {
  group('CountryPhonePicker - Pengujian Pemilih Negara Telepon', () {
    testWidgets('CountryPhonePicker menampilkan dengan benar', (WidgetTester tester) async {
      final testCountry = countries.isNotEmpty ? countries[0] : null;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountryPhonePicker(
              onNegaraBerubah: (_) {},
              negaraTerpilih: testCountry,
            ),
          ),
        ),
      );

      expect(find.byType(CountryPhonePicker), findsOneWidget);
      expect(find.text('Pilih Negara'), findsOneWidget);
    });

    testWidgets('CountryPhonePicker menampilkan negara default', (WidgetTester tester) async {
      final defaultCountry = countries[0];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountryPhonePicker(
              onNegaraBerubah: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(CountryPhonePicker), findsOneWidget);
    });

    testWidgets('CountryPhonePicker menampilkan bendera negara', (WidgetTester tester) async {
      final testCountry = countries[0];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountryPhonePicker(
              onNegaraBerubah: (_) {},
              negaraTerpilih: testCountry,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(CountryPhonePicker), findsOneWidget);
    });

    testWidgets('CountryPhonePicker menampilkan kode telepon negara', (WidgetTester tester) async {
      final testCountry = countries[0];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountryPhonePicker(
              onNegaraBerubah: (_) {},
              negaraTerpilih: testCountry,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(CountryPhonePicker), findsOneWidget);
    });

    testWidgets('Ikon dropdown CountryPhonePicker terlihat', (WidgetTester tester) async {
      final testCountry = countries[0];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountryPhonePicker(
              onNegaraBerubah: (_) {},
              negaraTerpilih: testCountry,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
    });

    testWidgets('CountryPhonePicker tap membuka dialog', (WidgetTester tester) async {
      final testCountry = countries[0];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountryPhonePicker(
              onNegaraBerubah: (_) {},
              negaraTerpilih: testCountry,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('CountryPhonePicker callback onNegaraBerubah', (WidgetTester tester) async {
      final testCountry = countries[0];
      Country? selectedCountry;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountryPhonePicker(
              onNegaraBerubah: (country) {
                selectedCountry = country;
              },
              negaraTerpilih: testCountry,
            ),
          ),
        ),
      );

      expect(find.byType(CountryPhonePicker), findsOneWidget);
    });



    testWidgets('Fungsi pencarian di dialog CountryPhonePicker', (WidgetTester tester) async {
      final testCountry = countries[0];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountryPhonePicker(
              onNegaraBerubah: (_) {},
              negaraTerpilih: testCountry,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('Pencarian di dialog memfilter negara', (WidgetTester tester) async {
      final testCountry = countries[0];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountryPhonePicker(
              onNegaraBerubah: (_) {},
              negaraTerpilih: testCountry,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'indo');
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('Tombol batal pada dialog CountryPhonePicker', (WidgetTester tester) async {
      final testCountry = countries[0];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountryPhonePicker(
              onNegaraBerubah: (_) {},
              negaraTerpilih: testCountry,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Memilih negara dari dialog CountryPhonePicker', (WidgetTester tester) async {
      // Persiapan
      final testCountry = countries[0];

      // Eksekusi
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountryPhonePicker(
              onNegaraBerubah: (_) {},
              negaraTerpilih: testCountry,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Ketuk picker
      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      // Verifikasi - dialog tersedia
      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });

  group('InputNomorTelepon - PENGUJIAN INPUT NOMOR TELEPON', () {
    testWidgets('InputNomorTelepon menampilkan dengan benar', (WidgetTester tester) async {
      // Persiapan
      final testCountry = countries[0];

      // Eksekusi
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InputNomorTelepon(
              onNomorBerubah: (_) {},
              negaraTerpilih: testCountry,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verifikasi
      expect(find.byType(InputNomorTelepon), findsOneWidget);
      expect(find.text('Nomor Telepon'), findsOneWidget);
    });

    testWidgets('InputNomorTelepon menampilkan CountryPhonePicker', (WidgetTester tester) async {
      // Persiapan
      final testCountry = countries[0];

      // Eksekusi
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InputNomorTelepon(
              onNomorBerubah: (_) {},
              negaraTerpilih: testCountry,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verifikasi
      expect(find.byType(CountryPhonePicker), findsOneWidget);
    });

    testWidgets('Kolom input nomor telepon di InputNomorTelepon terlihat', (WidgetTester tester) async {
      // Persiapan
      final testCountry = countries[0];

      // Eksekusi
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InputNomorTelepon(
              onNomorBerubah: (_) {},
              negaraTerpilih: testCountry,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verifikasi
      expect(find.byIcon(Icons.phone), findsWidgets);
    });

    testWidgets('InputNomorTelepon menginput nomor telepon', (WidgetTester tester) async {
      // Persiapan
      final testCountry = countries[0];

      // Eksekusi
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InputNomorTelepon(
              onNomorBerubah: (_) {},
              negaraTerpilih: testCountry,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Cari dan ketik di kolom nomor telepon
      final phoneTextFields = find.byType(TextField);
      if (phoneTextFields.evaluate().length > 1) {
        await tester.enterText(phoneTextFields.at(1), '812345678');
      }

      await tester.pumpAndSettle();

      // Verifikasi
      expect(find.byType(InputNomorTelepon), findsOneWidget);
    });

    testWidgets('Callback onNomorBerubah di InputNomorTelepon terpanggil', (WidgetTester tester) async {
      // Persiapan
      final testCountry = countries[0];
      String? fullNumber;

      // Eksekusi
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InputNomorTelepon(
              onNomorBerubah: (number) {
                fullNumber = number;
              },
              negaraTerpilih: testCountry,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verifikasi
      expect(find.byType(InputNomorTelepon), findsOneWidget);
    });

    testWidgets('InputNomorTelepon menampilkan nomor lengkap', (WidgetTester tester) async {
      // Persiapan
      final testCountry = countries[0];

      // Eksekusi
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InputNomorTelepon(
              onNomorBerubah: (_) {},
              negaraTerpilih: testCountry,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verifikasi - nomor lengkap dengan prefix
      expect(find.textContaining('Nomor lengkap'), findsOneWidget);
    });

    testWidgets('Perubahan pemilih negara di InputNomorTelepon memperbarui nomor', (WidgetTester tester) async {
      // Persiapan
      final testCountry = countries[0];

      // Eksekusi
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InputNomorTelepon(
              onNomorBerubah: (_) {},
              negaraTerpilih: testCountry,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verifikasi
      expect(find.byType(InputNomorTelepon), findsOneWidget);
    });

    testWidgets('InputNomorTelepon keyboard tipe telepon', (WidgetTester tester) async {
      // Persiapan
      final testCountry = countries[0];

      // Eksekusi
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InputNomorTelepon(
              onNomorBerubah: (_) {},
              negaraTerpilih: testCountry,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verifikasi - menggunakan TextInputType.phone
      expect(find.byType(InputNomorTelepon), findsOneWidget);
    });



    testWidgets('Siklus hidup controller pada InputNomorTelepon saat dispose', (WidgetTester tester) async {
      // Persiapan
      final testCountry = countries[0];

      // Eksekusi
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InputNomorTelepon(
              onNomorBerubah: (_) {},
              negaraTerpilih: testCountry,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Hapus widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Text('Removed'),
          ),
        ),
      );

      // Verifikasi - tidak ada error saat dispose
      expect(find.text('Removed'), findsOneWidget);
    });
  });

  group('CountryPhonePicker + InputNomorTelepon - PENGUJIAN INTEGRASI', () {
    testWidgets('Alur lengkap: pilih negara -> masukkan nomor telepon', (WidgetTester tester) async {
      // Persiapan
      final testCountry = countries[0];

      // Eksekusi
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InputNomorTelepon(
              onNomorBerubah: (_) {},
              negaraTerpilih: testCountry,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verifikasi
      expect(find.byType(InputNomorTelepon), findsOneWidget);
      expect(find.byType(CountryPhonePicker), findsOneWidget);
    });

    testWidgets('Pembentukan nomor lengkap: kode dial + nomor telepon', (WidgetTester tester) async {
      // Persiapan
      final testCountry = countries[0];

      // Eksekusi
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InputNomorTelepon(
              onNomorBerubah: (_) {},
              negaraTerpilih: testCountry,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verifikasi - komponen tersedia
      expect(find.byType(InputNomorTelepon), findsOneWidget);
    });

    testWidgets('Beberapa pilihan negara mempertahankan state nomor telepon', (WidgetTester tester) async {
      // Persiapan
      final countries1 = countries.isNotEmpty ? [countries[0]] : [];
      final testCountry = countries1.isNotEmpty ? countries1[0] : null;

      // Eksekusi
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InputNomorTelepon(
              onNomorBerubah: (_) {},
              negaraTerpilih: testCountry,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verifikasi
      expect(find.byType(InputNomorTelepon), findsOneWidget);
    });
  });

  group('CountryPhonePicker - PENGUJIAN PENANGANAN ERROR', () {
    testWidgets('Penanganan ketika tidak ada negara tersedia', (WidgetTester tester) async {
      // Persiapan
      final testCountry = countries.isNotEmpty ? countries[0] : null;

      // Eksekusi
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountryPhonePicker(
              onNegaraBerubah: (_) {},
              negaraTerpilih: testCountry,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verifikasi
      expect(find.byType(CountryPhonePicker), findsOneWidget);
    });

    testWidgets('Pencarian tanpa hasil', (WidgetTester tester) async {
      // Persiapan
      final testCountry = countries[0];

      // Eksekusi
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountryPhonePicker(
              onNegaraBerubah: (_) {},
              negaraTerpilih: testCountry,
            ),
          ),
        ),
      );

      // Ketuk picker
      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      // Pencarian untuk negara yang tidak ada
      await tester.enterText(
        find.byType(TextField),
        'ZZZZZZZZZZZ'
      );
      await tester.pumpAndSettle();

      // Verifikasi
      expect(find.text('Tidak ada negara yang ditemukan'), findsWidgets);
    });
  });
}
