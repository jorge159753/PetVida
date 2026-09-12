import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:petvida/screens/forgot_password_screen.dart';
import 'package:petvida/screens/home_screen.dart';
import 'package:petvida/screens/login_screen.dart';
import 'package:petvida/screens/register_screen.dart';
import 'package:petvida/widgets/petvida_logo.dart';

void main() {
  testWidgets('HomeScreen shows greeting and the four action cards', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.text('PetVida'), findsOneWidget);
    expect(find.textContaining('Bem-vindo(a) ao PetVida!'), findsOneWidget);
    expect(find.text('Meus Pets'), findsOneWidget);
    // "Linha do Tempo" aparece no card de ação e na navegação inferior.
    expect(find.text('Linha do Tempo'), findsNWidgets(2));
    expect(find.text('Clínicas e Campanhas'), findsOneWidget);
    expect(find.text('Diário de Sintomas'), findsOneWidget);
    expect(find.text('Adicionar Pet'), findsOneWidget);
  });

  testWidgets('LoginScreen shows the expected fields and actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    // A tela de login mostra a logo real (imagem), sem texto "PetVida"
    // separado — o nome já está desenhado dentro do selo.
    expect(find.byType(PetVidaLogo), findsOneWidget);
    expect(find.text('Digite o email'), findsOneWidget);
    expect(find.text('Digite a senha'), findsOneWidget);
    expect(find.text('esqueceu a senha'), findsOneWidget);
    expect(find.text('não tenho conta'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('LoginScreen shows validation message when fields are empty', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.tap(find.text('Login'));
    await tester.pump();

    expect(find.text('Preencha e-mail e senha.'), findsOneWidget);
  });

  testWidgets('Tapping "esqueceu a senha" opens ForgotPasswordScreen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.tap(find.text('esqueceu a senha'));
    await tester.pumpAndSettle();

    expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    expect(find.text('Digite seu e-mail'), findsOneWidget);
    expect(find.text('Enviar'), findsOneWidget);
  });

  testWidgets('Tapping "não tenho conta" opens RegisterScreen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.tap(find.text('não tenho conta'));
    await tester.pumpAndSettle();

    expect(find.byType(RegisterScreen), findsOneWidget);
    expect(find.text('Confirme a senha'), findsOneWidget);
    expect(find.text('Cadastrar'), findsOneWidget);
  });

  testWidgets('RegisterScreen shows validation message when fields are empty', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));

    await tester.tap(find.text('Cadastrar'));
    await tester.pump();

    expect(find.text('Preencha todos os campos.'), findsOneWidget);
  });

  testWidgets('ForgotPasswordScreen shows validation message for empty email', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ForgotPasswordScreen()));

    await tester.tap(find.text('Enviar'));
    await tester.pump();

    expect(find.text('Digite seu e-mail.'), findsOneWidget);
  });
}
