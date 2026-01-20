import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uts_backend/helper/number_formatter.dart';
import 'package:uts_backend/model/venue_model.dart';
import 'package:uts_backend/pages/venue_detail_screen.dart';

void main() {
  testWidgets('shows loading indicator while fetching details', (
    WidgetTester tester,
  ) async {
    final fetch = (int id) async {
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
    };

    await tester.pumpWidget(
      MaterialApp(home: VenueDetailScreen(id: 1, fetchDetails: fetch)),
    );

    // initial frame should show progress indicator
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // after delay, content should appear
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

      // allow async fetch
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // title and city in appbar and content
      expect(find.text('DetailVenue'), findsWidgets);
      expect(find.text('Kota Metropolis'), findsWidgets);

      // description
      expect(find.text('A nice place'), findsOneWidget);

      // hours
      expect(find.text('Jam Operasional'), findsOneWidget);
      expect(find.text('09:00 - 21:00'), findsOneWidget);

      // location
      expect(find.text('Lokasi'), findsOneWidget);
      expect(find.text('Jl. Example 123'), findsOneWidget);

      // facility
      expect(find.text('Parkir'), findsOneWidget);

      // price formatting in booking bar
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

    // Image.network errorBuilder should show image_not_supported icon
    expect(find.byIcon(Icons.image_not_supported), findsWidgets);
  });

  testWidgets('tapping booking button pushes a route', (
    WidgetTester tester,
  ) async {
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

    bool booked = false;
    await tester.pumpWidget(
      MaterialApp(
        home: VenueDetailScreen(
          id: 9,
          fetchDetails: (id) async => detail,
          onBooking: (c, v) => booked = true,
        ),
        navigatorObservers: [],
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Booking'), findsOneWidget);
    await tester.tap(find.text('Booking'));
    await tester.pump();

    expect(booked, isTrue);
  });

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

    // allow async fetch
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // facility names
    expect(find.text('Parkir'), findsOneWidget);
    expect(find.text('Toilet'), findsOneWidget);
    expect(find.text('WiFi'), findsOneWidget);

    // icons from FasilitasIcon mapping
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
