import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uts_backend/pages/profil.dart';

void main() {
  Widget makeTestableWidget() {
    return const MaterialApp(
      home: Profil(id: 1, testMode: true),
    );
  }

  testWidgets('1. Halaman profil bisa dirender', (tester) async {
    await tester.pumpWidget(makeTestableWidget());
    expect(find.byType(Profil), findsOneWidget);
  });

  testWidgets('2. Teks Profil Test tampil', (tester) async {
    await tester.pumpWidget(makeTestableWidget());
    expect(find.text('Profil Test'), findsOneWidget);
  });

  testWidgets('3. Icon kamera tampil', (tester) async {
    await tester.pumpWidget(makeTestableWidget());
    expect(find.byKey(const Key('camera_button')), findsOneWidget);
  });

  testWidgets('4. Dialog belum muncul di awal', (tester) async {
    await tester.pumpWidget(makeTestableWidget());
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('5. Klik kamera membuka dialog', (tester) async {
    await tester.pumpWidget(makeTestableWidget());
    await tester.tap(find.byKey(const Key('camera_button')));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('6. Judul dialog tampil', (tester) async {
    await tester.pumpWidget(makeTestableWidget());
    await tester.tap(find.byKey(const Key('camera_button')));
    await tester.pumpAndSettle();
    expect(find.text('Ubah Foto Profil'), findsOneWidget);
  });

  testWidgets('7. Tombol Galeri ada', (tester) async {
    await tester.pumpWidget(makeTestableWidget());
    await tester.tap(find.byKey(const Key('camera_button')));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.photo), findsOneWidget);
  });

  testWidgets('8. Tombol Kamera ada', (tester) async {
    await tester.pumpWidget(makeTestableWidget());
    await tester.tap(find.byKey(const Key('camera_button')));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.camera), findsOneWidget);
  });

  testWidgets('9. Tombol Batal ada', (tester) async {
    await tester.pumpWidget(makeTestableWidget());
    await tester.tap(find.byKey(const Key('camera_button')));
    await tester.pumpAndSettle();
    expect(find.text('Batal'), findsOneWidget);
  });

  testWidgets('10. Klik Batal menutup dialog', (tester) async {
    await tester.pumpWidget(makeTestableWidget());
    await tester.tap(find.byKey(const Key('camera_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('11. Icon kamera tetap ada', (tester) async {
    await tester.pumpWidget(makeTestableWidget());
    expect(find.byKey(const Key('camera_button')), findsOneWidget);
  });

  testWidgets('12. Dialog tidak muncul dobel', (tester) async {
    await tester.pumpWidget(makeTestableWidget());
    expect(find.byType(AlertDialog), findsNothing);
  });
}
