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
}
