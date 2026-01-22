import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uts_backend/helper/date_formatter.dart';
import 'package:uts_backend/helper/number_formatter.dart';
import 'package:uts_backend/pages/booking/choose_booking_schedule_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  group('ChooseBookingScheduleScreen base elements', () {
    setUpAll(() async {
      await initializeDateFormatting();
    });

    Future<void> pumpScreen(WidgetTester tester) async {
      final binding = tester.binding;
      binding.window.physicalSizeTestValue = const Size(800, 1200);
      binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(() {
        binding.window.clearPhysicalSizeTestValue();
        binding.window.clearDevicePixelRatioTestValue();
      });

      const jam = '08:00 - 22:00';
      const harga = '50000';
      const jumlahLapangan = 3;

      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            height: 1200,
            child: ChooseBookingScheduleScreen(
              venueId: 1,
              jamOperasional: jam,
              harga: harga,
              jumlahLapangan: jumlahLapangan,
              namaVenue: 'TestVenue',
              testMode: true,
              disableAds: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
    }

    testWidgets('renders header and date', (WidgetTester tester) async {
      await pumpScreen(tester);

      expect(find.text('Pilih Jadwal'), findsOneWidget);

      final today = DateTime.now();
      expect(find.text(DateFormatter.format('dd', today)), findsOneWidget);
    });

    testWidgets('renders lapangan list', (WidgetTester tester) async {
      await pumpScreen(tester);

      const jumlahLapangan = 3;
      for (int i = 1; i <= jumlahLapangan; i++) {
        expect(find.text('Lapangan $i'), findsOneWidget);
      }
    });

    testWidgets('shows time labels when within range', (
      WidgetTester tester,
    ) async {
      await pumpScreen(tester);

      const jam = '08:00 - 22:00';
      final jamBuka = int.parse(jam.split(' - ')[0].substring(0, 2));
      final jamTutup = int.parse(jam.split(' - ')[1].substring(0, 2));

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final nowDate = DateTime(now.year, now.month, now.day);
      final startHour = (nowDate == today && now.hour >= jamBuka)
          ? now.hour + 1
          : jamBuka;

      if (startHour <= jamTutup - 1) {
        final anyTimeLabelFound = find
            .byWidgetPredicate(
              (w) =>
                  w is Text && RegExp(r'^\d{1,2}:00\b').hasMatch(w.data ?? ''),
            )
            .evaluate()
            .isNotEmpty;

        expect(anyTimeLabelFound, isTrue);
      } else {
        expect(find.text(DateFormatter.format('dd', today)), findsOneWidget);
      }
    });

    testWidgets('shows price with or without symbol', (
      WidgetTester tester,
    ) async {
      await pumpScreen(tester);

      const harga = '50000';
      final expectedHargaWithSymbol = NumberFormatter.currency(
        int.parse(harga),
      );
      final expectedHargaNoSymbol = NumberFormatter.currency(
        int.parse(harga),
        symbol: "",
      );
      final hasHarga =
          find.text(expectedHargaWithSymbol).evaluate().isNotEmpty ||
          find.text(expectedHargaNoSymbol).evaluate().isNotEmpty;
      expect(hasHarga, isTrue);
    });
  });
}
