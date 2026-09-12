import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:petvida/screens/symptom_diary_screen.dart';

void main() {
  testWidgets('SymptomDiaryScreen shows title, symptoms and history', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SymptomDiaryScreen()));

    expect(find.text('Diário de Sintomas'), findsOneWidget);
    expect(find.text('Febre'), findsOneWidget);
    expect(find.text('Apetite'), findsOneWidget);
    expect(find.text('Letargia'), findsOneWidget);
    expect(find.text('Vômito'), findsOneWidget);
    expect(find.text('Tosse'), findsOneWidget);
    expect(find.text('Histórico de Registros'), findsOneWidget);
    expect(find.text('Adicionar Novo Registro de Sintoma'), findsOneWidget);
  });

  testWidgets('Shows a warning when adding a record without a symptom', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SymptomDiaryScreen()));

    final addButton = find.text('Adicionar Novo Registro de Sintoma');
    await tester.ensureVisible(addButton);
    await tester.tap(addButton);
    await tester.pump();

    expect(find.text('Selecione um sintoma.'), findsOneWidget);
  });

  testWidgets('Adding a record after selecting a symptom updates the history', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SymptomDiaryScreen()));

    await tester.tap(find.text('Febre'));
    await tester.pump();

    final addButton = find.text('Adicionar Novo Registro de Sintoma');
    await tester.ensureVisible(addButton);
    await tester.tap(addButton);
    await tester.pump();

    expect(find.text('Registro de sintoma adicionado!'), findsOneWidget);
    expect(find.textContaining('Hoje: Febre'), findsOneWidget);
  });
}
