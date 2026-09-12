import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:petvida/screens/medicamentos_screen.dart';

void main() {
  testWidgets('MedicamentosScreen shows the pet name and empty state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MedicamentosScreen(petId: 'abc123', nomePet: 'Fofo'),
      ),
    );

    expect(find.text('Medicamentos de Fofo'), findsOneWidget);
    // Sem Firebase inicializado (ambiente de teste), a tela mostra um aviso
    // em vez da lista/botão de adicionar.
    expect(
      find.text('Não foi possível carregar os medicamentos.'),
      findsOneWidget,
    );
  });
}
