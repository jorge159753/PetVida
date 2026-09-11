import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../theme/app_colors.dart';
import '../widgets/petvida_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _mensagemDeErro(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'user-disabled':
        return 'Esta conta foi desativada.';
      case 'user-not-found':
        return 'Não encontramos uma conta com esse e-mail.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      default:
        return 'Não foi possível entrar. Tente novamente.';
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final senha = _passwordController.text;

    if (email.isEmpty || senha.isEmpty) {
      _showSnackBar('Preencha e-mail e senha.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } on FirebaseAuthException catch (e) {
      _showSnackBar(_mensagemDeErro(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleEsqueceuSenha() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showSnackBar('Digite seu e-mail para receber o link de redefinição.');
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showSnackBar('Enviamos um e-mail para redefinir sua senha.');
    } on FirebaseAuthException catch (e) {
      _showSnackBar(_mensagemDeErro(e));
    }
  }

  void _handleNaoTenhoConta() {
    _showSnackBar('Cadastro em breve.');
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.laranjaArdente),
      filled: true,
      fillColor: AppColors.begePata,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cremeSuave,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 48),
              const PetVidaLogo(),
              const Spacer(flex: 3),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppColors.laranjaArdente),
                decoration: _inputDecoration('Digite o email'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: AppColors.laranjaArdente),
                decoration: _inputDecoration('Digite a senha'),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : _handleEsqueceuSenha,
                    child: const Text(
                      'esqueceu a senha',
                      style: TextStyle(color: AppColors.laranjaArdente),
                    ),
                  ),
                  TextButton(
                    onPressed: _isLoading ? null : _handleNaoTenhoConta,
                    child: const Text(
                      'não tenho conta',
                      style: TextStyle(color: AppColors.laranjaArdente),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.laranjaTerracota,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Login',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const Spacer(flex: 4),
            ],
          ),
        ),
      ),
    );
  }
}
