import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:petvida/screens/pet_profile_screen.dart';

void main() {
  testWidgets('PetProfileScreen shows default pet data and badges', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: PetProfileScreen()));

    expect(find.text('PetVida'), findsOneWidget);
    expect(find.text('Fofo'), findsOneWidget);
    expect(find.text('Gato / Idade: 2 anos'), findsOneWidget);
    expect(find.text('Vacina OK'), findsOneWidget);
    expect(find.text('Peso Ideal'), findsOneWidget);
    expect(find.text('Check-up em Dia'), findsOneWidget);

    expect(find.text('ADICIONAR VACINA'), findsOneWidget);
    expect(find.text('Histórico Médico'), findsOneWidget);
    expect(find.text('Medicamentos Atuais'), findsOneWidget);
    expect(find.text('Configurações do Pet'), findsOneWidget);
  });

  testWidgets('PetProfileScreen shows data passed via constructor', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: PetProfileScreen(
          nome: 'Mago',
          especie: 'Cão',
          idade: '4 anos',
          badges: ['Vacina OK'],
        ),
      ),
    );

    expect(find.text('Mago'), findsOneWidget);
    expect(find.text('Cão / Idade: 4 anos'), findsOneWidget);
    expect(find.text('Vacina OK'), findsOneWidget);
  });

  testWidgets('Tapping "ADICIONAR VACINA" shows a placeholder message', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: PetProfileScreen()));

    await tester.tap(find.text('ADICIONAR VACINA'));
    await tester.pump();

    expect(find.text('Em breve.'), findsOneWidget);
  });
}
