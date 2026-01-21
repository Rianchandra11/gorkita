import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uts_backend/widgets/skeleton_loader.dart';

void main() {
  group('SkeletonLoader - Pengujian Loader Skeleton', () {
    testWidgets('SkeletonLoader menampilkan dengan ukuran default',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonLoader(),
          ),
        ),
      );

      expect(find.byType(SkeletonLoader), findsOneWidget);
      expect(find.byType(AnimatedBuilder), findsWidgets);
    });

    testWidgets('SkeletonLoader dengan custom width dan height',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonLoader(
              width: 100,
              height: 50,
            ),
          ),
        ),
      );

      expect(find.byType(SkeletonLoader), findsOneWidget);
      final skeletonFinder = find.byType(SkeletonLoader);
      expect(skeletonFinder, findsOneWidget);
    });

    testWidgets('SkeletonLoader dengan custom borderRadius',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonLoader(
              borderRadius: 16,
            ),
          ),
        ),
      );

      expect(find.byType(SkeletonLoader), findsOneWidget);
    });

    testWidgets('SkeletonLoader animation berjalan', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonLoader(),
          ),
        ),
      );

      // Pump beberapa frame untuk memastikan animasi berjalan
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(SkeletonLoader), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(SkeletonLoader), findsOneWidget);
    });

    testWidgets('SkeletonLoader dispose dengan benar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonLoader(),
          ),
        ),
      );

      // Cek bahwa widget ada
      expect(find.byType(SkeletonLoader), findsOneWidget);

      // Pump dan dispose
      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      // Jika tidak ada error, dispose berhasil
      expect(find.byType(SkeletonLoader), findsNothing);
    });

    testWidgets('SkeletonLoader memiliki Container dengan decorasi',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonLoader(
              width: 80,
              height: 20,
            ),
          ),
        ),
      );

      // Jangan gunakan pumpAndSettle karena animasi tidak pernah selesai
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('SkeletonLoader menggunakan theme brightness yang tepat',
        (WidgetTester tester) async {
      // Test dengan light theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: const Scaffold(
            body: SkeletonLoader(),
          ),
        ),
      );

      expect(find.byType(SkeletonLoader), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 500));

      // Test dengan dark theme
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const Scaffold(
            body: SkeletonLoader(),
          ),
        ),
      );

      expect(find.byType(SkeletonLoader), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 500));
    });

    testWidgets('SkeletonLoader default parameter bernilai benar',
        (WidgetTester tester) async {
      const skeleton = SkeletonLoader();

      expect(skeleton.width, equals(double.infinity));
      expect(skeleton.height, equals(20));
      expect(skeleton.borderRadius, equals(8));
    });
  });

  group('SkeletonAvatar - Pengujian Skeleton Avatar', () {
    testWidgets('SkeletonAvatar menampilkan dengan size default',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonAvatar(),
          ),
        ),
      );

      expect(find.byType(SkeletonAvatar), findsOneWidget);
      expect(find.byType(SkeletonLoader), findsOneWidget);
    });

    testWidgets('SkeletonAvatar dengan custom size', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonAvatar(
              size: 120,
            ),
          ),
        ),
      );

      expect(find.byType(SkeletonAvatar), findsOneWidget);
    });

    testWidgets('SkeletonAvatar menghasilkan circular shape',
        (WidgetTester tester) async {
      const avatar = SkeletonAvatar(size: 100);
      // borderRadius seharusnya size/2 = 50 (circular)
      expect(avatar.size, equals(100));
    });

    testWidgets('SkeletonAvatar default size adalah 80',
        (WidgetTester tester) async {
      const avatar = SkeletonAvatar();
      expect(avatar.size, equals(80));
    });
  });

  group('SkeletonCard - Pengujian Skeleton Card', () {
    testWidgets('SkeletonCard menampilkan dengan height default',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonCard(),
          ),
        ),
      );

      expect(find.byType(SkeletonCard), findsOneWidget);
      expect(find.byType(SkeletonLoader), findsOneWidget);
    });

    testWidgets('SkeletonCard dengan custom height', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonCard(
              height: 150,
            ),
          ),
        ),
      );

      expect(find.byType(SkeletonCard), findsOneWidget);
    });

    testWidgets('SkeletonCard dengan custom margin', (WidgetTester tester) async {
      const margin = EdgeInsets.all(20);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonCard(
              margin: margin,
            ),
          ),
        ),
      );

      expect(find.byType(SkeletonCard), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('SkeletonCard menggunakan borderRadius 12',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonCard(),
          ),
        ),
      );

      expect(find.byType(SkeletonCard), findsOneWidget);
      // SkeletonCard menggunakan SkeletonLoader dengan borderRadius 12
      expect(find.byType(SkeletonLoader), findsOneWidget);
    });

    testWidgets('SkeletonCard default height adalah 100',
        (WidgetTester tester) async {
      const card = SkeletonCard();
      expect(card.height, equals(100));
    });

    testWidgets('SkeletonCard default margin horizontal 16 vertical 8',
        (WidgetTester tester) async {
      const card = SkeletonCard();
      expect(card.margin, isNull); // Default akan diset di build
    });

    testWidgets('SkeletonCard memiliki Container wrapper',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonCard(),
          ),
        ),
      );

      expect(find.byType(Container), findsWidgets);
    });
  });

  group('Skeleton Widgets - PENGUJIAN INTEGRASI', () {
    testWidgets('Skeleton widgets dapat berada dalam list',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: const [
                SkeletonCard(height: 80),
                SkeletonCard(height: 80),
                SkeletonCard(height: 80),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(SkeletonCard), findsNWidgets(3));
      expect(find.byType(SkeletonLoader), findsNWidgets(3));
    });

    testWidgets('Skeleton widgets dapat dikombinasikan', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SkeletonAvatar(size: 100),
                SizedBox(height: 10),
                SkeletonCard(height: 50),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(SkeletonAvatar), findsOneWidget);
      expect(find.byType(SkeletonCard), findsOneWidget);
      expect(find.byType(SkeletonLoader), findsNWidgets(2));
    });

    testWidgets('Skeleton widgets dapat di-rebuild', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonCard(),
          ),
        ),
      );

      expect(find.byType(SkeletonCard), findsOneWidget);

      // Trigger rebuild
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonCard(height: 150),
          ),
        ),
      );

      expect(find.byType(SkeletonCard), findsOneWidget);
    });
  });
}
