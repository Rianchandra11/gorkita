import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uts_backend/model/venue_model.dart';
import 'package:uts_backend/pages/venue_list_screen.dart';

void main() {
  testWidgets('displays venues from injected fetch function', (WidgetTester tester) async {
    final venue = VenueModel(
      venueId: 1,
      nama: 'Gor A',
      kota: 'Jakarta',
      harga: 50000,
      totalRating: 10,
      rating: 4.5,
      linkGambar: ['https://example.com/image.jpg'],
    );

    await tester.pumpWidget(MaterialApp(
      home: VenueListScreen(fetchVenues: () async => [venue]),
    ));

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

    await tester.pumpWidget(MaterialApp(
      home: VenueListScreen(fetchVenues: () async => [v1, v2, v3]),
    ));

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
}
