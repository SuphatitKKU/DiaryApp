// Basic widget test for Aurora Diaries app.

import 'package:flutter_test/flutter_test.dart';

import 'package:diaryapp/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AuroraDiariesApp());

    // Verify that intro screen is displayed
    expect(find.text('Magic in Every Page'), findsOneWidget);
    expect(find.text('Start Writing'), findsOneWidget);
  });
}
