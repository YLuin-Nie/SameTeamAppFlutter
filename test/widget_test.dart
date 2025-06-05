import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:same_team_flutter/main.dart'; // ✅ assumes pubspec.yaml name matches

void main() {
  testWidgets('SameTeamApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp()); // ✅ root widget

    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('Sign In'), findsWidgets); // adjust as needed
  });
}
