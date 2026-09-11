import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:petvida/screens/meus_pets_screen.dart';
import 'package:petvida/screens/pet_profile_screen.dart';

void main() {
  testWidgets('MeusPetsScreen shows title, pets and their status badges', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: MeusPetsScreen()));

    expect(find.text('PetVida'), findsOneWidget);
    expect(find.text('Meus Pets'), findsOneWidget);

    expect(find.text('Fofo'), findsOneWidget);
    expect(find.text('Mago'), findsOneWidget);
    expect(find.text('Bolo'), findsOneWidget);
    expect(find.text('Amarelo'), findsOneWidget);
    expect(find.text('Cão / Gato'), findsNWidgets(4));

    expect(find.text('Vacina OK'), findsNWidgets(2));
    expect(find.text('Carteira Completa'), findsNWidgets(2));
    expect(find.text('Próxima Vacina'), findsNWidgets(2));
    expect(find.text('Falta Diário'), findsNWidgets(2));

    expect(find.text('Adicionar Pet'), findsOneWidget);
  });

  testWidgets('Tapping a pet card opens PetProfileScreen with its data', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: MeusPetsScreen()));

    await tester.tap(find.text('Fofo'));
    await tester.pumpAndSettle();

    expect(find.byType(PetProfileScreen), findsOneWidget);
    expect(find.text('Fofo'), findsOneWidget);
    expect(find.text('Gato / Idade: 2 anos'), findsOneWidget);
  });

  testWidgets('Tapping "Adicionar Pet" shows a placeholder message', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: MeusPetsScreen()));

    await tester.ensureVisible(find.text('Adicionar Pet'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Adicionar Pet'));
    await tester.pump();

    expect(find.text('Em breve.'), findsOneWidget);
  });
}
