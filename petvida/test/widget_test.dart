import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:petvida/main.dart';
import 'package:petvida/screens/login_screen.dart';

void main() {
  testWidgets('HomePage shows PetVida title', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomePage()));

    expect(find.text('PetVida'), findsOneWidget);
  });

  testWidgets('LoginScreen shows the expected fields and actions',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    expect(find.text('PetVida'), findsOneWidget);
    expect(find.text('Digite o email'), findsOneWidget);
    expect(find.text('Digite a senha'), findsOneWidget);
    expect(find.text('esqueceu a senha'), findsOneWidget);
    expect(find.text('não tenho conta'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('LoginScreen shows validation message when fields are empty',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.text('Preencha e-mail e senha.'), findsOneWidget);
  });
}
