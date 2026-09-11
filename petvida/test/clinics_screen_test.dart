import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:petvida/screens/clinics_screen.dart';

void main() {
  testWidgets(
      'ClinicsScreen shows search bar, clinics and campaigns',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ClinicsScreen()));

    expect(find.text('Clínicas e Campanhas'), findsOneWidget);
    expect(find.text('Buscar clínicas ou campanhas...'), findsOneWidget);
    // Nome da clínica aparece no pin do mapa e no card da lista.
    expect(find.text('Clínica Veterinária Patinhas'), findsNWidgets(2));
    expect(find.text('Clínica Veterinária Mago'), findsNWidgets(2));
    expect(find.text('Vacinação Antirrábica 2024'), findsNWidgets(2));
    expect(find.text('Saiba Mais'), findsNWidgets(2));
  });

  testWidgets('Searching filters clinics and campaigns by name',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ClinicsScreen()));

    await tester.enterText(
      find.byType(TextField),
      'Mago',
    );
    await tester.pump();

    expect(find.text('Clínica Veterinária Mago'), findsNWidgets(2));
    expect(find.text('Clínica Veterinária Patinhas'), findsNothing);
    expect(find.text('Vacinação Antirrábica 2024'), findsNothing);
  });

  testWidgets('Searching for something with no match shows empty message',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ClinicsScreen()));

    await tester.enterText(find.byType(TextField), 'inexistente');
    await tester.pump();

    expect(find.text('Nenhum resultado encontrado.'), findsOneWidget);
  });

  testWidgets('Tapping "Saiba Mais" shows a snack bar',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ClinicsScreen()));

    await tester.scrollUntilVisible(
      find.text('Saiba Mais').first,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Saiba Mais').first);
    await tester.pump();

    expect(find.text('Em breve.'), findsOneWidget);
  });
}
