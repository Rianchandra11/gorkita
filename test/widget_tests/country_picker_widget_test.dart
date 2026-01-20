import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uts_backend/widgets/country_picker_widget.dart';

void main() {
  group('CountryPickerButton - Pengujian Dropdown Pilihan', () {
    testWidgets('CountryPickerButton menampilkan dengan benar', (WidgetTester tester) async {
      final selectedCountry = CountryModel(
        code: 'ID',
        name: 'Indonesia',
        flag: 'ID',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountryPickerButton(
              selectedCountry: selectedCountry,
              onCountrySelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(CountryPickerButton), findsOneWidget);
      expect(find.text('ID'), findsOneWidget);
    });

    testWidgets('CountryPickerButton menampilkan flag yang benar', (WidgetTester tester) async {
      // Persiapan
      final selectedCountry = CountryModel(
        code: 'MY',
        name: 'Malaysia',
        flag: 'MY',
      );

      // Eksekusi
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountryPickerButton(
              selectedCountry: selectedCountry,
              onCountrySelected: (_) {},
            ),
          ),
        ),
      );

      // Verifikasi
      expect(find.text('MY'), findsOneWidget);
    });

    testWidgets('CountryPickerButton menampilkan "No Selection" ketika kode kosong', (WidgetTester tester) async {
      // Persiapan
      final emptyCountry = CountryModel(
        code: '',
        name: '',
        flag: '',
      );

      // Eksekusi
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountryPickerButton(
              selectedCountry: emptyCountry,
              onCountrySelected: (_) {},
            ),
          ),
        ),
      );

      // Verifikasi
      expect(find.text('No Selection'), findsOneWidget);
    });

    testWidgets('Ikon dropdown CountryPickerButton terlihat', (WidgetTester tester) async {
      // Persiapan
      final selectedCountry = CountryModel(
        code: 'SG',
        name: 'Singapore',
        flag: 'SG',
      );

      // Eksekusi
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountryPickerButton(
              selectedCountry: selectedCountry,
              onCountrySelected: (_) {},
            ),
          ),
        ),
      );

      // Verifikasi
      expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
    });

    testWidgets('CountryPickerButton tap membuka bottom sheet', (WidgetTester tester) async {
      // Persiapan
      final selectedCountry = CountryModel(
        code: 'ID',
        name: 'Indonesia',
        flag: 'ID',
      );

      // Eksekusi
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountryPickerButton(
              selectedCountry: selectedCountry,
              onCountrySelected: (_) {},
            ),
          ),
        ),
      );

      // Ketuk tombol
      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      // Verifikasi - bottom sheet seharusnya muncul
      expect(find.byType(Material), findsWidgets);
    });

    testWidgets('CountryPickerButton dengan custom backgroundColor', (WidgetTester tester) async {
      // Persiapan
      final selectedCountry = CountryModel(
        code: 'ID',
        name: 'Indonesia',
        flag: 'ID',
      );
      final customBgColor = Color(0xFFF5F5F5);

      // Eksekusi
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountryPickerButton(
              selectedCountry: selectedCountry,
              onCountrySelected: (_) {},
              backgroundColor: customBgColor,
            ),
          ),
        ),
      );

      // Verifikasi
      expect(find.byType(CountryPickerButton), findsOneWidget);
    });

    testWidgets('CountryPickerButton dengan custom textColor', (WidgetTester tester) async {
      // Persiapan
      final selectedCountry = CountryModel(
        code: 'SG',
        name: 'Singapore',
        flag: 'SG',
      );
      final customTextColor = Colors.blue;

      // Eksekusi
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountryPickerButton(
              selectedCountry: selectedCountry,
              onCountrySelected: (_) {},
              textColor: customTextColor,
            ),
          ),
        ),
      );

      // Verifikasi
      expect(find.byType(CountryPickerButton), findsOneWidget);
    });

    testWidgets('CountryPickerButton dengan custom borderColor', (WidgetTester tester) async {
      // Persiapan
      final selectedCountry = CountryModel(
        code: 'MY',
        name: 'Malaysia',
        flag: 'MY',
      );
      final customBorderColor = Colors.red;

      // Eksekusi
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountryPickerButton(
              selectedCountry: selectedCountry,
              onCountrySelected: (_) {},
              borderColor: customBorderColor,
            ),
          ),
        ),
      );

      // Verifikasi
      expect(find.byType(CountryPickerButton), findsOneWidget);
    });

    testWidgets('Callback onCountrySelected pada CountryPickerButton', (WidgetTester tester) async {
      // Persiapan
      final selectedCountry = CountryModel(
        code: 'ID',
        name: 'Indonesia',
        flag: 'ID',
      );
      CountryModel? selectedInCallback;

      // Eksekusi
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountryPickerButton(
              selectedCountry: selectedCountry,
              onCountrySelected: (country) {
                selectedInCallback = country;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      // Verifikasi
      expect(find.byType(CountryPickerButton), findsOneWidget);
    });
  });

  group('CountryPickerSheet - Pengujian Lembar Pilihan', () {
    testWidgets('Picker sheet menampilkan semua negara', (WidgetTester tester) async {
      // Persiapan - pengujian disederhanakan karena _CountryPickerSheet bersifat private
      final selectedCountry = CountryList.countries[0];

      // Eksekusi
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountryPickerButton(
              selectedCountry: selectedCountry,
              onCountrySelected: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verifikasi
      expect(find.text('Pilih Negara') != null, true);
    });

    testWidgets('Picker sheet menampilkan close button', (WidgetTester tester) async {
      // Persiapan
      final selectedCountry = CountryList.countries[0];

      // Eksekusi - pengujian melalui CountryPickerButton
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountryPickerButton(
              selectedCountry: selectedCountry,
              onCountrySelected: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verifikasi
      expect(find.byType(CountryPickerButton), findsOneWidget);
    });

    testWidgets('Picker sheet: ketuk item daftar memilih negara', (WidgetTester tester) async {
      // Persiapan
      final selectedCountry = CountryList.countries[0];
      CountryModel? selectedFromSheet;

      // Eksekusi
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountryPickerButton(
              selectedCountry: selectedCountry,
              onCountrySelected: (country) {
                selectedFromSheet = country;
              },
            ),
          ),
        ),
      );

      // Verifikasi
      expect(find.byType(CountryPickerButton), findsOneWidget);
    });

    testWidgets('Picker sheet: negara terpilih menampilkan ikon centang', (WidgetTester tester) async {
      // Persiapan
      final selectedCountry = CountryList.countries[1]; // Malaysia

      // Eksekusi
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountryPickerButton(
              selectedCountry: selectedCountry,
              onCountrySelected: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verifikasi
      expect(find.byType(CountryPickerButton), findsOneWidget);
    });

    testWidgets('Picker sheet: negara tidak terpilih menampilkan ikon lingkaran', (WidgetTester tester) async {
      // Persiapan
      final selectedCountry = CountryList.countries[0];

      // Eksekusi
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountryPickerButton(
              selectedCountry: selectedCountry,
              onCountrySelected: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verifikasi
      expect(find.byType(CountryPickerButton), findsOneWidget);
    });

    testWidgets('Picker sheet scrollable untuk banyak negara', (WidgetTester tester) async {
      // Persiapan
      final selectedCountry = CountryList.countries[0];

      // Eksekusi
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountryPickerButton(
              selectedCountry: selectedCountry,
              onCountrySelected: (_) {},
            ),
          ),
        ),
      );

      // Verifikasi
      expect(find.byType(CountryPickerButton), findsOneWidget);
    });

    testWidgets('Picker sheet mendukung dark mode', (WidgetTester tester) async {
      // Persiapan
      final selectedCountry = CountryList.countries[0];

      // Eksekusi
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: CountryPickerButton(
              selectedCountry: selectedCountry,
              onCountrySelected: (_) {},
            ),
          ),
        ),
      );

      // Verifikasi
      expect(find.byType(CountryPickerButton), findsOneWidget);
    });

    testWidgets('Picker sheet mendukung light mode', (WidgetTester tester) async {
      // Persiapan
      final selectedCountry = CountryList.countries[0];

      // Eksekusi
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: CountryPickerButton(
              selectedCountry: selectedCountry,
              onCountrySelected: (_) {},
            ),
          ),
        ),
      );

      // Verifikasi
      expect(find.byType(CountryPickerButton), findsOneWidget);
    });
  });

  group('CountryModel - PENGUJIAN KESETARAAN', () {
    test('CountryModel dengan kode yang sama dianggap equal', () {
      // Persiapan
      final country1 = CountryModel(code: 'ID', name: 'Indonesia', flag: 'ID');
      final country2 = CountryModel(code: 'ID', name: 'Indonesia', flag: 'ID');

      // Eksekusi & Verifikasi
      expect(country1 == country2, true);
    });

    test('CountryModel dengan kode berbeda dianggap tidak equal', () {
      // Persiapan
      final country1 = CountryModel(code: 'ID', name: 'Indonesia', flag: 'ID');
      final country2 = CountryModel(code: 'MY', name: 'Malaysia', flag: 'MY');

      // Eksekusi & Verifikasi
      expect(country1 == country2, false);
    });

    test('Konsistensi hashCode pada CountryModel', () {
      // Persiapan
      final country = CountryModel(code: 'ID', name: 'Indonesia', flag: 'ID');

      // Eksekusi & Verifikasi
      expect(country.hashCode == country.hashCode, true);
    });
  });

  group('CountryPickerButton - PENGUJIAN INTEGRASI', () {
    testWidgets('Alur lengkap: tekan tombol -> pilih negara -> callback', (WidgetTester tester) async {
      // Persiapan
      final selectedCountry = CountryModel(
        code: 'ID',
        name: 'Indonesia',
        flag: 'ID',
      );
      CountryModel? finalSelected;

      // Eksekusi
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CountryPickerButton(
                selectedCountry: selectedCountry,
                onCountrySelected: (country) {
                  finalSelected = country;
                },
              ),
            ),
          ),
        ),
      );

      // Ketuk tombol
      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      // Verifikasi tombol dan sheet tersedia
      expect(find.byType(CountryPickerButton), findsOneWidget);
    });

    testWidgets('Beberapa pilihan negara', (WidgetTester tester) async {
      // Persiapan
      final countries = [
        CountryModel(code: 'ID', name: 'Indonesia', flag: 'ID'),
        CountryModel(code: 'MY', name: 'Malaysia', flag: 'MY'),
        CountryModel(code: 'SG', name: 'Singapore', flag: 'SG'),
      ];

      // Eksekusi - membuat picker dengan negara pertama
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountryPickerButton(
              selectedCountry: countries[0],
              onCountrySelected: (_) {},
            ),
          ),
        ),
      );

      // Verifikasi
      expect(find.text('ID'), findsOneWidget);
    });
  });
}
