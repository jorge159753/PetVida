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

  testWidgets('ClinicsScreen shows search bar, clinics and campaigns', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ClinicsScreen()));
    await tester.pump();

    expect(find.text('Clínicas e Campanhas'), findsOneWidget);
    expect(find.text('Buscar clínicas ou campanhas...'), findsOneWidget);
    expect(find.text('Clínica Veterinária Vida Animal'), findsOneWidget);
    expect(find.text('Hospital Veterinário São Francisco'), findsOneWidget);
    expect(find.text('Clínica Pet Amigo'), findsOneWidget);
    expect(find.text('Vacinação Antirrábica 2026'), findsOneWidget);
    expect(find.text('Mutirão de Castração'), findsOneWidget);
    expect(find.text('Saiba Mais'), findsNWidgets(2));
  });

  testWidgets('Searching filters clinics and campaigns by name', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ClinicsScreen()));
    await tester.pump();

    await tester.enterText(find.byType(TextField), 'Amigo');
    await tester.pump();

    expect(find.text('Clínica Pet Amigo'), findsOneWidget);
    expect(find.text('Clínica Veterinária Vida Animal'), findsNothing);
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

  testWidgets('Tapping a clinic card copies its info and shows a snack bar', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ClinicsScreen()));
    await tester.pump();

    await tester.scrollUntilVisible(
      find.text('Clínica Pet Amigo').last,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Clínica Pet Amigo').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Informações da clínica copiadas!'), findsOneWidget);
  });
}
