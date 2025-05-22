import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:same_team_flutter/main.dart';

void main() {
  testWidgets('SameTeamApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SameTeamApp());

    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('Sign In'), findsWidgets); // Adjust this if you use different button labels
  });
}
