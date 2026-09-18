import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../services/notification_service.dart';
import '../theme/app_colors.dart';
import '../widgets/paw_prints_background.dart';
import '../widgets/petvida_logo.dart';
import 'clinics_screen.dart';
import 'login_screen.dart';
import 'timeline_screen.dart';

/// Tela de Perfil (conta do tutor).
class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  String get _email {
    if (Firebase.apps.isEmpty) return '';
    return FirebaseAuth.instance.currentUser?.email ?? '';
  }

  void _abrirTela(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleSair(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cremeSuave,
        title: const Text(
          'Sair da conta',
          style: TextStyle(
            color: AppColors.laranjaTerracota,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text('Tem certeza que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.laranjaTerracota,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _handleExcluirConta(BuildContext context) async {
    if (Firebase.apps.isEmpty || FirebaseAuth.instance.currentUser == null) {
      _showSnackBar(context, 'Não é possível excluir a conta agora.');
      return;
    }

    final sucesso = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _DeleteAccountDialog(),
    );

    if (sucesso == true && context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cremeSuave,
      body: PawPrintsBackground(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.amareloPorDoSol, AppColors.laranjaSolar],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: const Center(child: PetVidaLogo(size: 64)),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const CircleAvatar(
                        radius: 48,
                        backgroundColor: AppColors.begePata,
                        child: Icon(
                          Icons.person,
                          size: 48,
                          color: AppColors.laranjaTerracota,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _email,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: () => _handleSair(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.laranjaTerracota,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          icon: const Icon(Icons.logout),
                          label: const Text(
                            'Sair da conta',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed: () => _handleExcluirConta(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          icon: const Icon(Icons.delete_forever),
                          label: const Text(
                            'Excluir conta',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        selectedItemColor: AppColors.laranjaTerracota,
        unselectedItemColor: Colors.black45,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.of(context).popUntil((route) => route.isFirst);
            case 1:
              _abrirTela(context, const ClinicsScreen());
            case 2:
              _abrirTela(context, const TimelineScreen());
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Clínicas'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Linha do Tempo',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

/// Confirmação de exclusão definitiva da conta (RF12/RNF03 - LGPD): pede a
/// senha do tutor para reautenticar (exigência do Firebase para operações
/// sensíveis), apaga todos os dados do tutor e dos pets no Firestore, cancela
/// os lembretes locais pendentes e por fim exclui a conta do Firebase Auth.
class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _senhaController = TextEditingController();
  bool _processando = false;
  String? _erro;

  @override
  void dispose() {
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _excluirColecao(
    CollectionReference<Map<String, dynamic>> colecao,
  ) async {
    final snapshot = await colecao.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> _excluirTodosOsDados(String uid) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(uid);

    final petsSnapshot = await userDoc.collection('pets').get();
    for (final petDoc in petsSnapshot.docs) {
      await _excluirColecao(petDoc.reference.collection('vacinas'));

      final medicamentosSnapshot = await petDoc.reference
          .collection('medicamentos')
          .get();
      for (final medDoc in medicamentosSnapshot.docs) {
        await _excluirColecao(medDoc.reference.collection('doses'));
        await medDoc.reference.delete();
      }

      await _excluirColecao(petDoc.reference.collection('historico'));
      await petDoc.reference.delete();
    }

    await _excluirColecao(userDoc.collection('sintomas'));
    await _excluirColecao(userDoc.collection('eventos'));

    await userDoc.delete();
  }

  Future<void> _handleConfirmar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _processando = true;
      _erro = null;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      setState(() {
        _processando = false;
        _erro = 'Não foi possível identificar a conta atual.';
      });
      return;
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _senhaController.text,
      );
      await user.reauthenticateWithCredential(credential);

      await _excluirTodosOsDados(user.uid);

      try {
        await NotificationService.instance.cancelarTudo();
      } catch (_) {
        // Não impede a exclusão da conta.
      }

      await user.delete();

      if (mounted) Navigator.of(context).pop(true);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _processando = false;
        _erro = switch (e.code) {
          'wrong-password' ||
          'invalid-credential' => 'Senha incorreta.',
          'too-many-requests' =>
            'Muitas tentativas. Tente novamente mais tarde.',
          _ => 'Não foi possível excluir a conta (${e.code}).',
        };
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _processando = false;
        _erro =
            'Não foi possível excluir a conta. Verifique sua conexão e '
            'tente novamente.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cremeSuave,
      title: const Text(
        'Excluir conta',
        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Isso apaga permanentemente sua conta e todos os dados dos '
              'seus pets (vacinas, medicamentos, sintomas e linha do '
              'tempo). Essa ação não pode ser desfeita.',
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _senhaController,
              obscureText: true,
              enabled: !_processando,
              decoration: const InputDecoration(
                labelText: 'Confirme sua senha',
              ),
              validator: (value) => (value == null || value.isEmpty)
                  ? 'Digite sua senha para confirmar'
                  : null,
            ),
            if (_erro != null) ...[
              const SizedBox(height: 12),
              Text(
                _erro!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ],
            if (_processando) ...[
              const SizedBox(height: 16),
              const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _processando
              ? null
              : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _processando ? null : _handleConfirmar,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Excluir tudo'),
        ),
      ],
    );
  }
}
