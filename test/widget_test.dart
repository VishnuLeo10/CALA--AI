// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// 1. Import your main.dart file which contains your root widget
import 'package:calai/main.dart';

void main() {
  // 2. We are no longer testing a counter, so we rename the test
  testWidgets('LoginScreen has welcome text and a login button', (
    WidgetTester tester,
  ) async {
    // 3. Build our app, not the default 'MyApp', but your 'CALAIApp'
    await tester.pumpWidget(const CALAIApp());

    // Because your app's initialRoute is '/login', the LoginScreen will be displayed.
    // Now we can verify that widgets on the LoginScreen are present.

    // Verify that the welcome text is shown.
    expect(find.text('Welcome to CALAI'), findsOneWidget);
    expect(find.text('Your AI Diet Companion'), findsOneWidget);

    // Verify that the email and password fields (TextFields) exist.
    expect(find.byType(TextField), findsNWidgets(2));

    // Verify the login button is present.
    // Using widgetWithText is more specific than just find.text('Login')
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);

    // Verify the register button text is present.
    expect(find.text("Don't have an account? Register"), findsOneWidget);

    // This checks that the old counter app text is NOT present.
    expect(find.text('0'), findsNothing);
    expect(find.byIcon(Icons.add), findsNothing);
  });
}
