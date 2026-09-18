import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:petvida/screens/clinics_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') return null;
          return null;
        });
  });

  // Sem o plugin de geolocalização/rede disponível no ambiente de teste, a
  // tela nunca consegue buscar clínicas reais (Overpass API) — o que é
  // esperado, já que não há mais dados mocados de São Paulo como fallback.
  // Os testes abaixo cobrem a estrutura da tela e a busca/campanhas, que
  // continuam funcionando independentemente da geolocalização.

  testWidgets('ClinicsScreen shows search bar and campaigns', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ClinicsScreen()));
    await tester.pump();

    expect(find.text('Clínicas e Campanhas'), findsOneWidget);
    expect(find.text('Buscar clínicas ou campanhas...'), findsOneWidget);
    expect(find.text('Vacinação Antirrábica 2026'), findsOneWidget);
    expect(find.text('Mutirão de Castração'), findsOneWidget);
    expect(find.text('Saiba Mais'), findsNWidgets(2));
  });

  testWidgets('Searching filters campaigns by name', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ClinicsScreen()));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'Castração');
    await tester.pump();

    expect(find.text('Mutirão de Castração'), findsOneWidget);
    expect(find.text('Vacinação Antirrábica 2026'), findsNothing);
  });

  testWidgets('Searching for something with no match shows empty message', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ClinicsScreen()));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'inexistente');
    await tester.pump();

    expect(find.text('Nenhum resultado encontrado.'), findsOneWidget);
  });

  testWidgets(
    'Shows the category filter chips (RF08): Clínicas, CCZ, Vacinação Gratuita, Castração',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ClinicsScreen()));
      await tester.pump();

      expect(find.widgetWithText(FilterChip, 'Clínicas'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'CCZ'), findsOneWidget);
      expect(
        find.widgetWithText(FilterChip, 'Vacinação Gratuita'),
        findsOneWidget,
      );
      expect(find.widgetWithText(FilterChip, 'Castração'), findsOneWidget);
    },
  );

  testWidgets(
    'Deselecting the "Vacinação Gratuita" category hides that campaign only',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ClinicsScreen()));
      await tester.pump();

      await tester.tap(find.widgetWithText(FilterChip, 'Vacinação Gratuita'));
      await tester.pump();

      expect(find.text('Vacinação Antirrábica 2026'), findsNothing);
      expect(find.text('Mutirão de Castração'), findsOneWidget);
    },
  );

  testWidgets(
    'Deselecting the "Castração" category hides that campaign only',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ClinicsScreen()));
      await tester.pump();

      await tester.tap(find.widgetWithText(FilterChip, 'Castração'));
      await tester.pump();

      expect(find.text('Mutirão de Castração'), findsNothing);
      expect(find.text('Vacinação Antirrábica 2026'), findsOneWidget);
    },
  );

  testWidgets('Tapping "Saiba Mais" opens a dialog with full campaign info', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ClinicsScreen()));
    await tester.pump();

    await tester.scrollUntilVisible(
      find.text('Saiba Mais').first,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Saiba Mais').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Fechar'), findsOneWidget);
  });
}
