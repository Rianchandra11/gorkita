import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uts_backend/helper/number_formatter.dart';
import 'package:uts_backend/model/venue_model.dart';
import 'package:uts_backend/pages/venue_detail_screen.dart';
import 'package:uts_backend/pages/booking/choose_booking_schedule_screen.dart';

void main() {
  testWidgets('shows loading indicator while fetching details', (
    WidgetTester tester,
  ) async {
    Future<VenueModel> fetch(int id) async {
      await Future.delayed(const Duration(seconds: 1));
      return VenueModel(
        venueId: id,
        nama: 'V',
        kota: 'C',
        deskripsi: 'D',
        jamOperasional: '09:00 - 18:00',
        jumlahLapangan: 1,
        harga: 10000,
        alamat: 'Addr',
        linkGambar: ['https://example.com/x.jpg'],
        fasilitas: [],
      );
    }

    await tester.pumpWidget(
      MaterialApp(home: VenueDetailScreen(id: 1, fetchDetails: fetch)),
    );

    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(find.text('V'), findsWidgets);
  });

  testWidgets(
    'renders venue content: title, city, description, hours, location, facilities, price',
    (WidgetTester tester) async {
      final detail = VenueModel(
        venueId: 5,
        nama: 'DetailVenue',
        kota: 'Metropolis',
        deskripsi: 'A nice place',
        jamOperasional: '09:00 - 21:00',
        jumlahLapangan: 3,
        harga: 75000,
        alamat: 'Jl. Example 123',
        linkGambar: ['https://example.com/img.jpg'],
        fasilitas: [FacilityModel(facilityId: 1, nama: 'Parkir')],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: VenueDetailScreen(id: 5, fetchDetails: (id) async => detail),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('DetailVenue'), findsWidgets);
      expect(find.text('Kota Metropolis'), findsWidgets);

      expect(find.text('A nice place'), findsOneWidget);

      expect(find.text('Jam Operasional'), findsOneWidget);
      expect(find.text('09:00 - 21:00'), findsOneWidget);

      expect(find.text('Lokasi'), findsOneWidget);
      expect(find.text('Jl. Example 123'), findsOneWidget);

      expect(find.text('Parkir'), findsOneWidget);

      final expected = NumberFormatter.currency(75000);
      expect(find.text(expected), findsOneWidget);
    },
  );

  testWidgets('image error shows image_not_supported icon', (
    WidgetTester tester,
  ) async {
    final detail = VenueModel(
      venueId: 6,
      nama: 'BrokenImgVenue',
      kota: 'Nowhere',
      deskripsi: 'Desc',
      jamOperasional: '08:00 - 20:00',
      jumlahLapangan: 1,
      harga: 10000,
      alamat: 'Addr',
      linkGambar: ['http://invalid'],
      fasilitas: [],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: VenueDetailScreen(id: 6, fetchDetails: (id) async => detail),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byIcon(Icons.image_not_supported), findsWidgets);
  });

  testWidgets(
    'tapping booking button navigate to choose_booking_schedule_screen',
    (WidgetTester tester) async {
      final detail = VenueModel(
        venueId: 9,
        nama: 'Bookable',
        kota: 'City',
        deskripsi: 'Desc',
        jamOperasional: '07:00 - 23:00',
        jumlahLapangan: 2,
        harga: 50000,
        alamat: 'Addr',
        linkGambar: ['https://example.com/x.jpg'],
        fasilitas: [],
      );
      final observer = _TestNavigatorObserver();

      await tester.pumpWidget(
        MaterialApp(
          home: VenueDetailScreen(id: 9, fetchDetails: (id) async => detail),
          navigatorObservers: [observer],
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Booking'), findsOneWidget);

      final elevated = find.byType(ElevatedButton);
      final ElevatedButton btn = tester.widget<ElevatedButton>(elevated);
      btn.onPressed?.call();

      expect(observer.pushed.length, greaterThanOrEqualTo(1));

      final lastRoute = observer.pushed.last as MaterialPageRoute<dynamic>;
      final BuildContext ctx = tester.element(find.byType(VenueDetailScreen));
      final destWidget = lastRoute.builder(ctx);
      expect(destWidget, isA<ChooseBookingScheduleScreen>());
    },
  );

  testWidgets('facility icons correspond to fasilitas ids', (
    WidgetTester tester,
  ) async {
    final detail = VenueModel(
      venueId: 11,
      nama: 'FacilityVenue',
      kota: 'City',
      deskripsi: 'Has facilities',
      jamOperasional: '08:00 - 22:00',
      jumlahLapangan: 2,
      harga: 20000,
      alamat: 'Addr',
      linkGambar: ['https://example.com/x.jpg'],
      fasilitas: [
        FacilityModel(facilityId: 4, nama: 'Parkir'),
        FacilityModel(facilityId: 2, nama: 'Toilet'),
        FacilityModel(facilityId: 6, nama: 'WiFi'),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: VenueDetailScreen(id: 11, fetchDetails: (id) async => detail),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Parkir'), findsOneWidget);
    expect(find.text('Toilet'), findsOneWidget);
    expect(find.text('WiFi'), findsOneWidget);

    expect(find.byIcon(Icons.local_parking), findsOneWidget);
    expect(find.byIcon(Icons.wc), findsOneWidget);
    expect(find.byIcon(Icons.wifi), findsOneWidget);
  });
}

class _TestNavigatorObserver extends NavigatorObserver {
  final List<Route> pushed = [];
  @override
  void didPush(Route route, Route? previousRoute) {
    pushed.add(route);
    super.didPush(route, previousRoute);
  }
}
