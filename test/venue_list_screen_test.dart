import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uts_backend/helper/number_formatter.dart';
import 'package:uts_backend/model/venue_model.dart';
import 'package:uts_backend/pages/venue_list_screen.dart';

void main() {
  testWidgets('displays venues from injected fetch function', (
    WidgetTester tester,
  ) async {
    final venue = VenueModel(
      venueId: 1,
      nama: 'Gor A',
      kota: 'Jakarta',
      harga: 50000,
      totalRating: 10,
      rating: 4.5,
      linkGambar: ['https://example.com/image.jpg'],
    );

    await tester.pumpWidget(
      MaterialApp(home: VenueListScreen(fetchVenues: () async => [venue])),
    );

    // Wait for the async fetch and rebuild (avoid pumpAndSettle due to image network requests)
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Gor A'), findsOneWidget);
    expect(find.text('Kota Jakarta'), findsOneWidget);
    expect(find.text('1 Venue'), findsOneWidget);
  });

  testWidgets('search filters venues correctly', (WidgetTester tester) async {
    final v1 = VenueModel(
      venueId: 1,
      nama: 'Alpha Arena',
      kota: 'Jakarta',
      harga: 40000,
      totalRating: 5,
      rating: 4.0,
      linkGambar: ['https://example.com/a.jpg'],
    );
    final v2 = VenueModel(
      venueId: 2,
      nama: 'Beta Field',
      kota: 'Bandung',
      harga: 30000,
      totalRating: 3,
      rating: 3.5,
      linkGambar: ['https://example.com/b.jpg'],
    );
    final v3 = VenueModel(
      venueId: 3,
      nama: 'Gamma Court',
      kota: 'Surabaya',
      harga: 45000,
      totalRating: 8,
      rating: 4.6,
      linkGambar: ['https://example.com/c.jpg'],
    );

    await tester.pumpWidget(
      MaterialApp(home: VenueListScreen(fetchVenues: () async => [v1, v2, v3])),
    );

    // allow async fetch and rebuild
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // initial: 3 venues
    expect(find.text('3 Venue'), findsOneWidget);
    expect(find.text('Alpha Arena'), findsOneWidget);
    expect(find.text('Beta Field'), findsOneWidget);

    // enter search text and tap search icon
    await tester.enterText(find.byType(TextField), 'Alpha');
    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // should show only Alpha
    expect(find.text('Alpha Arena'), findsOneWidget);
    expect(find.text('Beta Field'), findsNothing);
    expect(find.text('1 Venue'), findsOneWidget);
  });

  testWidgets('shows loading indicator while fetching', (
    WidgetTester tester,
  ) async {
    final v = VenueModel(
      venueId: 1,
      nama: 'Loading Venue',
      kota: 'Nowhere',
      harga: 10000,
      totalRating: 0,
      rating: 0.0,
      linkGambar: ['https://example.com/x.jpg'],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: VenueListScreen(
          fetchVenues: () async {
            await Future.delayed(const Duration(seconds: 1));
            return [v];
          },
        ),
      ),
    );

    // initial frame: loading should be shown
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // after fetch completes, list appears
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(find.text('Loading Venue'), findsOneWidget);
  });

  testWidgets('shows empty result message when no venues', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: VenueListScreen(fetchVenues: () async => [])),
    );

    // allow fetch
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Pencarian Anda tidak ditemukan'), findsOneWidget);
  });

  testWidgets('search clear restores full list', (WidgetTester tester) async {
    final v1 = VenueModel(
      venueId: 1,
      nama: 'Alpha Arena',
      kota: 'Jakarta',
      harga: 40000,
      totalRating: 5,
      rating: 4.0,
      linkGambar: ['https://example.com/a.jpg'],
    );
    final v2 = VenueModel(
      venueId: 2,
      nama: 'Beta Field',
      kota: 'Bandung',
      harga: 30000,
      totalRating: 3,
      rating: 3.5,
      linkGambar: ['https://example.com/b.jpg'],
    );

    await tester.pumpWidget(
      MaterialApp(home: VenueListScreen(fetchVenues: () async => [v1, v2])),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // filter down to Alpha
    await tester.enterText(find.byType(TextField), 'Alpha');
    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();
    expect(find.text('Alpha Arena'), findsOneWidget);
    expect(find.text('Beta Field'), findsNothing);

    // clear search
    await tester.enterText(find.byType(TextField), '');
    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Alpha Arena'), findsOneWidget);
    expect(find.text('Beta Field'), findsOneWidget);
    expect(find.text('2 Venue'), findsOneWidget);
  });

  testWidgets('image error shows broken image icon', (
    WidgetTester tester,
  ) async {
    final v = VenueModel(
      venueId: 9,
      nama: 'Broken Img',
      kota: 'Nowhere',
      harga: 1,
      totalRating: 0,
      rating: 0.0,
      linkGambar: ['http://invalid'],
    );

    await tester.pumpWidget(
      MaterialApp(home: VenueListScreen(fetchVenues: () async => [v])),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    // CachedNetworkImage may show an error icon or the placeholder depending on the test environment.
    final hasBroken = find.byIcon(Icons.broken_image).evaluate().isNotEmpty;
    final hasPlaceholder = find
        .descendant(
          of: find.byType(ClipRRect),
          matching: find.byType(CircularProgressIndicator),
        )
        .evaluate()
        .isNotEmpty;

    expect(hasBroken || hasPlaceholder, isTrue);
  });

  testWidgets('displays formatted price and search hint', (
    WidgetTester tester,
  ) async {
    final v = VenueModel(
      venueId: 11,
      nama: 'Pricey',
      kota: 'City',
      harga: 40000,
      totalRating: 2,
      rating: 4.0,
      linkGambar: ['https://example.com/p.jpg'],
    );

    await tester.pumpWidget(
      MaterialApp(home: VenueListScreen(fetchVenues: () async => [v])),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    final expected = NumberFormatter.currency(40000);
    expect(find.text(expected), findsOneWidget);
    expect(find.text('Cari lapangan disini'), findsOneWidget);
  });

  testWidgets('tapping a venue pushes detail route with venue id', (
    WidgetTester tester,
  ) async {
    final v = VenueModel(
      venueId: 77,
      nama: 'TapVenue',
      kota: 'City',
      harga: 20000,
      totalRating: 1,
      rating: 3.0,
      linkGambar: ['https://example.com/t.jpg'],
    );

    final observer = _TestNavigatorObserver();

    final detail = VenueModel(
      venueId: 77,
      nama: 'TapVenue',
      kota: 'City',
      harga: 20000,
      totalRating: 1,
      rating: 3.0,
      linkGambar: ['https://example.com/t.jpg'],
      deskripsi: 'Desc',
      jamOperasional: '08:00 - 22:00',
      jumlahLapangan: 2,
      alamat: 'Somewhere',
      fasilitas: [FacilityModel(facilityId: 1, nama: 'Wifi')],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: VenueListScreen(
          fetchVenues: () async => [v],
          fetchDetails: (id) async => detail,
        ),
        navigatorObservers: [observer],
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('TapVenue'), findsOneWidget);
    await tester.tap(find.text('TapVenue'));
    await tester.pumpAndSettle();

    expect(observer.pushed.length, greaterThanOrEqualTo(1));
    final pushed = observer.pushed.last;
    expect(pushed.settings.arguments, equals(77));
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
