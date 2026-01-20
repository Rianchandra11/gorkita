import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uts_backend/pages/reset_password.dart';
import 'package:uts_backend/database/services/app_service.dart';

// Fake AppService untuk mencegah inisialisasi Firebase saat widget test
class FakeAppService implements AppService {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('ResetPasswordPage - Pengujian Kode Reset', () {
    testWidgets('Menampilkan kode reset saat resetCode diberikan', (WidgetTester tester) async {
      const email = 'user@example.com';
      const resetCode = '123456';

      await tester.pumpWidget(
        MaterialApp(
          home: ResetPasswordPage(
            email: email,
            resetCode: resetCode,
            apiService: FakeAppService(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Kode Reset:'), findsOneWidget);
      expect(find.text(resetCode), findsOneWidget);
    });

    testWidgets('Tidak menampilkan kode reset saat resetCode null', (WidgetTester tester) async {
      const email = 'user@example.com';

      await tester.pumpWidget(
        MaterialApp(
          home: ResetPasswordPage(
            email: email,
            apiService: FakeAppService(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Kode Reset:'), findsNothing);
    });
  });
}
