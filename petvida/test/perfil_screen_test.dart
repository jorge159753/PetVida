import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:petvida/screens/perfil_screen.dart';
import 'package:petvida/widgets/petvida_logo.dart';

void main() {
  testWidgets('PerfilScreen shows logo, sign-out and delete-account buttons', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: PerfilScreen()));

    expect(find.byType(PetVidaLogo), findsOneWidget);
    expect(find.text('Sair da conta'), findsOneWidget);
    expect(find.text('Excluir conta'), findsOneWidget);
  });

  testWidgets(
    'Tapping "Excluir conta" without Firebase tells the user it is unavailable',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: PerfilScreen()));

      await tester.tap(find.text('Excluir conta'));
      await tester.pump();

      expect(
        find.text('Não é possível excluir a conta agora.'),
        findsOneWidget,
      );
    },
  );
}
