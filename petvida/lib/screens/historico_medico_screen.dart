import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/paw_prints_background.dart';
import '../widgets/petvida_logo.dart';

/// Histórico médico de um pet (users/{uid}/pets/{petId}/historico).
class HistoricoMedicoScreen extends StatelessWidget {
  const HistoricoMedicoScreen({
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
        .collection('historico');
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleAdicionar(BuildContext context) async {
    final collection = _collection;
    if (collection == null) {
      _showSnackBar(context, 'Não é possível adicionar um registro agora.');
      return;
    }

    final dados = await showDialog<Map<String, Object>>(
      context: context,
      builder: (_) => const _RegistroDialog(
        titulo: 'Novo Registro',
        labelDescricao: 'Descrição (ex: Consulta de rotina)',
      ),
    );
    if (dados == null) return;

    try {
      await collection.add({
        'descricao': dados['descricao'],
        'data': dados['data'],
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (context.mounted) {
        _showSnackBar(context, 'Registro adicionado com sucesso!');
      }
    } catch (_) {
      if (context.mounted) {
        _showSnackBar(context, 'Não foi possível adicionar o registro.');
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
                      'Histórico Médico de $nomePet',
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
                        child: Text('Não foi possível carregar o histórico.'),
                      )
                    : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: collection
                            .orderBy('data', descending: true)
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
                                      'Nenhum registro ainda.',
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  ),
                                )
                              else
                                for (final doc in docs) ...[
                                  _RegistroTile(
                                    icon: Icons.local_hospital,
                                    data: doc.data(),
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
                                    'Adicionar Registro',
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

class _RegistroTile extends StatelessWidget {
  const _RegistroTile({required this.icon, required this.data});

  final IconData icon;
  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final descricao = (data['descricao'] as String?) ?? '';
    final timestamp = data['data'] as Timestamp?;
    final dataTexto = timestamp == null
        ? 'Data não informada'
        : _formatarData(timestamp.toDate());
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
          Icon(icon, color: AppColors.laranjaTerracota),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  descricao,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  dataTexto,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String _formatarData(DateTime data) {
  final dia = data.day.toString().padLeft(2, '0');
  final mes = data.month.toString().padLeft(2, '0');
  return '$dia/$mes/${data.year}';
}

class _RegistroDialog extends StatefulWidget {
  const _RegistroDialog({required this.titulo, required this.labelDescricao});

  final String titulo;
  final String labelDescricao;

  @override
  State<_RegistroDialog> createState() => _RegistroDialogState();
}

class _RegistroDialogState extends State<_RegistroDialog> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  DateTime _data = DateTime.now();

  @override
  void dispose() {
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _escolherData() async {
    final selecionada = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (selecionada != null) setState(() => _data = selecionada);
  }

  void _handleSalvar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop({
      'descricao': _descricaoController.text.trim(),
      'data': Timestamp.fromDate(_data),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cremeSuave,
      title: Text(
        widget.titulo,
        style: const TextStyle(
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
              controller: _descricaoController,
              decoration: InputDecoration(labelText: widget.labelDescricao),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Preencha esse campo'
                  : null,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Data'),
              subtitle: Text(_formatarData(_data)),
              trailing: const Icon(
                Icons.calendar_today,
                color: AppColors.laranjaTerracota,
              ),
              onTap: _escolherData,
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
