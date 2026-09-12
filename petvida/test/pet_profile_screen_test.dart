import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:petvida/screens/pet_profile_screen.dart';
import 'package:petvida/widgets/petvida_logo.dart';

void main() {
  testWidgets('PetProfileScreen shows default pet data and badges', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: PetProfileScreen()));

    expect(find.byType(PetVidaLogo), findsOneWidget);
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

  testWidgets(
    'Tapping "ADICIONAR VACINA" without a petId tells the user it is unavailable',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: PetProfileScreen()));

      await tester.tap(find.text('ADICIONAR VACINA'));
      await tester.pump();

      expect(
        find.text('Não é possível adicionar vacina para este pet.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Edit icon and delete button are hidden without a petId (no Firestore doc to change)',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: PetProfileScreen()));

      expect(find.byIcon(Icons.edit), findsNothing);
      expect(find.text('Excluir Pet'), findsNothing);
      expect(find.byIcon(Icons.camera_alt), findsNothing);
    },
  );

  testWidgets(
    'Tapping "Histórico Médico" without a petId tells the user it is unavailable',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: PetProfileScreen()));

      await tester.ensureVisible(find.text('Histórico Médico'));
      await tester.tap(find.text('Histórico Médico'));
      await tester.pump();

      expect(
        find.text('Não é possível abrir o histórico deste pet.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Tapping "Medicamentos Atuais" without a petId tells the user it is unavailable',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: PetProfileScreen()));

      await tester.ensureVisible(find.text('Medicamentos Atuais'));
      await tester.tap(find.text('Medicamentos Atuais'));
      await tester.pump();

      expect(
        find.text('Não é possível abrir os medicamentos deste pet.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'Tapping "Configurações do Pet" without a petId tells the user it is unavailable',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: PetProfileScreen()));

      await tester.ensureVisible(find.text('Configurações do Pet'));
      await tester.tap(find.text('Configurações do Pet'));
      await tester.pump();

      expect(find.text('Não é possível editar este pet.'), findsOneWidget);
    },
  );
}
