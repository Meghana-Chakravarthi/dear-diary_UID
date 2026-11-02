import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('SecretDiaryApp shows the splash and login flow', (WidgetTester tester) async {
    await tester.pumpWidget(const SecretDiaryApp());

    expect(find.text('Secret Diary'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 1800));
    await tester.pumpAndSettle();

    expect(find.text('Create your password'), findsOneWidget);
  });
}
