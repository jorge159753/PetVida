import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:petvida/screens/historico_medico_screen.dart';

void main() {
  testWidgets('HistoricoMedicoScreen shows the pet name and empty state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HistoricoMedicoScreen(petId: 'abc123', nomePet: 'Fofo'),
      ),
    );

    expect(find.text('Histórico Médico de Fofo'), findsOneWidget);
    // Sem Firebase inicializado (ambiente de teste), a tela mostra um aviso
    // em vez da lista/botão de adicionar.
    expect(find.text('Não foi possível carregar o histórico.'), findsOneWidget);
  });
}
