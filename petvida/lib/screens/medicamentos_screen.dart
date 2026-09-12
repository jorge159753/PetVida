import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/paw_prints_background.dart';
import '../widgets/petvida_logo.dart';

/// Medicamentos atuais de um pet (users/{uid}/pets/{petId}/medicamentos).
class MedicamentosScreen extends StatelessWidget {
  const MedicamentosScreen({
    super.key,
    required this.petId,
    required this.nomePet,
  });

  final String petId;
  final String nomePet;

  CollectionReference<Map<String, dynamic>>? get _collection {
    if (Firebase.apps.isEmpty) return null;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('pets')
        .doc(petId)
        .collection('medicamentos');
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleAdicionar(BuildContext context) async {
    final collection = _collection;
    if (collection == null) {
      _showSnackBar(context, 'Não é possível adicionar um medicamento agora.');
      return;
    }

    final dados = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const _MedicamentoDialog(),
    );
    if (dados == null) return;

    try {
      await collection.add({
        'nome': dados['nome'],
        'dosagem': dados['dosagem'],
        'frequencia': dados['frequencia'],
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (context.mounted) {
        _showSnackBar(context, 'Medicamento adicionado com sucesso!');
      }
    } catch (_) {
      if (context.mounted) {
        _showSnackBar(context, 'Não foi possível adicionar o medicamento.');
      }
    }
  }

  Future<void> _handleExcluir(
    BuildContext context,
    DocumentReference<Map<String, dynamic>> doc,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cremeSuave,
        title: const Text('Remover Medicamento'),
        content: const Text('Tem certeza que deseja remover este medicamento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    try {
      await doc.delete();
    } catch (_) {
      if (context.mounted) {
        _showSnackBar(context, 'Não foi possível remover o medicamento.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final collection = _collection;
    return Scaffold(
      backgroundColor: AppColors.cremeSuave,
      body: PawPrintsBackground(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
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
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).maybePop(),
                          child: const CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.laranjaTerracota,
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Center(child: PetVidaLogo(size: 64)),
                        ),
                        const SizedBox(width: 36),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Medicamentos de $nomePet',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.laranjaTerracota,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: collection == null
                    ? const Center(
                        child: Text(
                          'Não foi possível carregar os medicamentos.',
                        ),
                      )
                    : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: collection
                            .orderBy('createdAt', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          final docs = snapshot.data?.docs ?? [];
                          return ListView(
                            padding: const EdgeInsets.all(20),
                            children: [
                              if (docs.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 32),
                                  child: Center(
                                    child: Text(
                                      'Nenhum medicamento cadastrado.',
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  ),
                                )
                              else
                                for (final doc in docs) ...[
                                  _MedicamentoTile(
                                    data: doc.data(),
                                    onExcluir: () =>
                                        _handleExcluir(context, doc.reference),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton.icon(
                                  onPressed: () => _handleAdicionar(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.laranjaTerracota,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  icon: const Icon(Icons.add),
                                  label: const Text(
                                    'Adicionar Medicamento',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MedicamentoTile extends StatelessWidget {
  const _MedicamentoTile({required this.data, required this.onExcluir});

  final Map<String, dynamic> data;
  final VoidCallback onExcluir;

  @override
  Widget build(BuildContext context) {
    final nome = (data['nome'] as String?) ?? 'Medicamento';
    final dosagem = (data['dosagem'] as String?) ?? '';
    final frequencia = (data['frequencia'] as String?) ?? '';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.medication, color: AppColors.laranjaTerracota),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                if (dosagem.isNotEmpty)
                  Text(
                    'Dosagem: $dosagem',
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                if (frequencia.isNotEmpty)
                  Text(
                    'Frequência: $frequencia',
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: onExcluir,
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
      ),
    );
  }
}

class _MedicamentoDialog extends StatefulWidget {
  const _MedicamentoDialog();

  @override
  State<_MedicamentoDialog> createState() => _MedicamentoDialogState();
}

class _MedicamentoDialogState extends State<_MedicamentoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _dosagemController = TextEditingController();
  final _frequenciaController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _dosagemController.dispose();
    _frequenciaController.dispose();
    super.dispose();
  }

  void _handleSalvar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop({
      'nome': _nomeController.text.trim(),
      'dosagem': _dosagemController.text.trim(),
      'frequencia': _frequenciaController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cremeSuave,
      title: const Text(
        'Adicionar Medicamento',
        style: TextStyle(
          color: AppColors.laranjaTerracota,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome do medicamento',
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Digite o nome do medicamento'
                  : null,
            ),
            TextFormField(
              controller: _dosagemController,
              decoration: const InputDecoration(
                labelText: 'Dosagem (ex: 1 comprimido)',
              ),
            ),
            TextFormField(
              controller: _frequenciaController,
              decoration: const InputDecoration(
                labelText: 'Frequência (ex: a cada 12h)',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _handleSalvar,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.laranjaTerracota,
            foregroundColor: Colors.white,
          ),
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
