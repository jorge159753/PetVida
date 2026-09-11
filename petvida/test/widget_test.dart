import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:petvida/main.dart';

void main() {
  testWidgets('HomePage shows PetVida title', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));

    expect(find.text('PetVida'), findsOneWidget);
  });
}
