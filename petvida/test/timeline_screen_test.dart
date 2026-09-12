import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:petvida/screens/timeline_screen.dart';

void main() {
  testWidgets('TimelineScreen shows title, actions and mock events', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: TimelineScreen()));

    // "Linha do Tempo" aparece no título e na navegação inferior.
    expect(find.text('Linha do Tempo'), findsNWidgets(2));
    expect(find.text('Filtros'), findsOneWidget);
    expect(find.text('Novo Evento'), findsOneWidget);
    expect(find.text('Vacinação: V8 e Raiva (Mago)'), findsOneWidget);
    expect(find.text('Check-up Anual (Bolo)'), findsOneWidget);
    expect(find.text('Primeiro Dia em Casa (Amarelo)'), findsOneWidget);
    expect(find.text('Completou Carteira de Fofo!'), findsOneWidget);
  });

  testWidgets('Tapping "Novo Evento" opens a dialog to add an event', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: TimelineScreen()));

    await tester.tap(find.text('Novo Evento'));
    await tester.pumpAndSettle();

    expect(find.text('Título'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Título'), 'Banho');
    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();

    expect(find.text('Evento adicionado!'), findsOneWidget);
    expect(find.text('Banho'), findsOneWidget);
  });

  testWidgets('Tapping "Filtros" opens a dialog to filter by pet', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: TimelineScreen()));

    await tester.tap(find.text('Filtros'));
    await tester.pumpAndSettle();

    expect(find.text('Filtrar por pet'), findsOneWidget);
    await tester.tap(find.text('Mago').last);
    await tester.pumpAndSettle();

    expect(find.text('Vacinação: V8 e Raiva (Mago)'), findsOneWidget);
    expect(find.text('Check-up Anual (Bolo)'), findsNothing);
  });
}
