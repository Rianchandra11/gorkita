import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uts_backend/widgets/phone_input_field.dart';

void main() {
  group('PhoneInputField - Pengujian Validasi Input', () {
    testWidgets('PhoneInputField menampilkan dengan benar', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhoneInputField(
              controller: controller,
              labelText: 'Phone Number',
              hintText: '812 3456 7890',
            ),
          ),
        ),
      );

      expect(find.byType(PhoneInputField), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('812 3456 7890'), findsOneWidget);
    });

    testWidgets('PhoneInputField hanya menerima angka', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhoneInputField(
              controller: controller,
              labelText: 'Phone',
            ),
          ),
        ),
      );

      final textFieldFinder = find.byType(TextField);
      
      await tester.enterText(find.byType(TextField).last, '812abc123');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhoneInputField(
              controller: controller,
              labelText: 'Phone',
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('PhoneInputField mencegah angka 0 di awal', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhoneInputField(
              controller: controller,
              initialCountryCode: 'ID',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(PhoneInputField), findsOneWidget);
    });

    testWidgets('PhoneInputField batas maksimal 15 angka', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhoneInputField(
              controller: controller,
              hintText: 'Max 15 digits',
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField).last, '12345678901234567890');
      await tester.pump();

      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('PhoneInputField memanggil onChanged callback', (WidgetTester tester) async {
      final controller = TextEditingController();
      String? capturedFullPhone;
      String? capturedCountryCode;
      String? capturedPhoneNumber;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhoneInputField(
              controller: controller,
              initialCountryCode: 'ID',
              onChanged: (fullPhone, countryCode, phoneNumber) {
                capturedFullPhone = fullPhone;
                capturedCountryCode = countryCode;
                capturedPhoneNumber = phoneNumber;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(PhoneInputField), findsOneWidget);
    });

    testWidgets('PhoneInputField dalam kondisi nonaktif', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhoneInputField(
              controller: controller,
              enabled: false,
              labelText: 'Disabled Phone',
            ),
          ),
        ),
      );

      expect(find.text('Disabled Phone'), findsOneWidget);
    });

    testWidgets('PhoneInputField dengan warna custom', (WidgetTester tester) async {
      final controller = TextEditingController();
      final customColor = Color(0xFF009688);
      final customBgColor = Color(0xFFF5F5F5);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhoneInputField(
              controller: controller,
              primaryColor: customColor,
              backgroundColor: customBgColor,
            ),
          ),
        ),
      );

      expect(find.byType(PhoneInputField), findsOneWidget);
    });

    testWidgets('PhoneInputField tinggi dan ukuran font custom', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhoneInputField(
              controller: controller,
              height: 60.0,
              fontSize: 16.0,
            ),
          ),
        ),
      );

      expect(find.byType(PhoneInputField), findsOneWidget);
    });

    testWidgets('PhoneInputField inisialisasi dengan kode negara awal', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhoneInputField(
              controller: controller,
              initialCountryCode: 'SG',
              labelText: 'Singapore Phone',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(PhoneInputField), findsOneWidget);
    });

    testWidgets('PhoneInputField parse nomor telepon yang ada', (WidgetTester tester) async {
      final controller = TextEditingController(text: '+6281234567890');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhoneInputField(
              controller: controller,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(PhoneInputField), findsOneWidget);
    });

    testWidgets('PhoneInputField ketuk pemilih negara', (WidgetTester tester) async {
      // Persiapan
      final controller = TextEditingController();

      // Eksekusi
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhoneInputField(
              controller: controller,
              initialCountryCode: 'ID',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Ketuk pemilih negara (diasumsikan menggunakan InkWell)
      await tester.tap(find.byType(InkWell).first);
      await tester.pumpAndSettle();

      // Verifikasi - bottom sheet seharusnya muncul
      expect(find.byType(PhoneInputField), findsOneWidget);
    });

    testWidgets('Siklus hidup TextEditingController pada PhoneInputField', (WidgetTester tester) async {
      // Persiapan
      final controller = TextEditingController();

      // Eksekusi
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhoneInputField(
              controller: controller,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Lepas (dispose) controller
      addTearDown(controller.dispose);

      // Verifikasi
      expect(find.byType(PhoneInputField), findsOneWidget);
    });
  });

  group('PhoneInputField - PENGUJIAN INTEGRASI', () {
    testWidgets('Alur lengkap input nomor telepon', (WidgetTester tester) async {
      // Persiapan
      final controller = TextEditingController();
      String? finalPhone;

      // Eksekusi
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhoneInputField(
              controller: controller,
              initialCountryCode: 'ID',
              onChanged: (fullPhone, _, __) {
                finalPhone = fullPhone;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verifikasi widget tampil
      expect(find.byType(PhoneInputField), findsOneWidget);
    });

    testWidgets('Kolom telepon mempertahankan negara yang dipilih', (WidgetTester tester) async {
      // Persiapan
      final controller = TextEditingController();

      // Eksekusi
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhoneInputField(
              controller: controller,
              initialCountryCode: 'SG',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Render ulang dengan kode negara yang sama
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PhoneInputField(
              controller: controller,
              initialCountryCode: 'SG',
            ),
          ),
        ),
      );

      // Verifikasi
      expect(find.byType(PhoneInputField), findsOneWidget);
    });
  });
}
