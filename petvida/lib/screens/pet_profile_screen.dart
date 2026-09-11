import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Tela de perfil do pet (ver imagens/perfil pet.png).
///
/// Quando [petId] é informado e o Firebase está inicializado, o botão
/// "Adicionar Vacina" salva em users/{uid}/pets/{petId}/vacinas no
/// Firestore e a lista de vacinas é exibida em tempo real.
class PetProfileScreen extends StatelessWidget {
  const PetProfileScreen({
    super.key,
    this.petId,
    this.nome = 'Fofo',
    this.especie = 'Gato',
    this.idade = '2 anos',
    this.badges = const ['Vacina OK', 'Peso Ideal', 'Check-up em Dia'],
  });

  final String? petId;
  final String nome;
  final String especie;
  final String idade;
  final List<String> badges;

  CollectionReference<Map<String, dynamic>>? get _vacinasCollection {
    if (petId == null || Firebase.apps.isEmpty) return null;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('pets')
        .doc(petId)
        .collection('vacinas');
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleAdicionarVacina(BuildContext context) async {
    final collection = _vacinasCollection;
    if (collection == null) {
      _showSnackBar(context, 'Não é possível adicionar vacina para este pet.');
      return;
    }

    final dados = await showDialog<Map<String, Object>>(
      context: context,
      builder: (_) => const _AddVaccineDialog(),
    );
    if (dados == null) return;

    try {
      await collection.add({
        'nome': dados['nome'],
        'dataAplicacao': dados['dataAplicacao'],
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (context.mounted) {
        _showSnackBar(context, 'Vacina adicionada com sucesso!');
      }
    } catch (_) {
      if (context.mounted) {
        _showSnackBar(context, 'Não foi possível adicionar a vacina.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vacinasCollection = _vacinasCollection;
    return Scaffold(
      backgroundColor: AppColors.cremeSuave,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PetHeader(
                nome: nome,
                especie: especie,
                idade: idade,
                badges: badges,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  children: [
                    _AddVaccineButton(
                      onTap: () => _handleAdicionarVacina(context),
                    ),
                    if (vacinasCollection != null) ...[
                      const SizedBox(height: 20),
                      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: vacinasCollection
                            .orderBy('dataAplicacao', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          final docs = snapshot.data?.docs ?? [];
                          return _VaccinesSection(docs: docs);
                        },
                      ),
                    ],
                    const SizedBox(height: 20),
                    _PetListItem(
                      icon: Icons.local_hospital,
                      label: 'Histórico Médico',
                      onTap: () => _showSnackBar(context, 'Em breve.'),
                    ),
                    const SizedBox(height: 16),
                    _PetListItem(
                      icon: Icons.medication,
                      label: 'Medicamentos Atuais',
                      onTap: () => _showSnackBar(context, 'Em breve.'),
                    ),
                    const SizedBox(height: 16),
                    _PetListItem(
                      icon: Icons.settings,
                      label: 'Configurações do Pet',
                      onTap: () => _showSnackBar(context, 'Em breve.'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _PetProfileBottomNav(
        onTap: () => _showSnackBar(context, 'Em breve.'),
      ),
    );
  }
}

String _formatarData(DateTime data) {
  final dia = data.day.toString().padLeft(2, '0');
  final mes = data.month.toString().padLeft(2, '0');
  return '$dia/$mes/${data.year}';
}

class _VaccinesSection extends StatelessWidget {
  const _VaccinesSection({required this.docs});

  final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vacinas Registradas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.laranjaTerracota,
          ),
        ),
        const SizedBox(height: 12),
        if (docs.isEmpty)
          const Text(
            'Nenhuma vacina registrada ainda.',
            style: TextStyle(color: Colors.black54),
          )
        else
          for (final doc in docs) ...[
            _VaccineTile(data: doc.data()),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _VaccineTile extends StatelessWidget {
  const _VaccineTile({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final nome = (data['nome'] as String?) ?? 'Vacina';
    final timestamp = data['dataAplicacao'] as Timestamp?;
    final dataTexto =
        timestamp == null ? 'Data não informada' : _formatarData(timestamp.toDate());
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
        children: [
          const Icon(Icons.vaccines, color: AppColors.laranjaTerracota),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  'Aplicada em $dataTexto',
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

class _PetHeader extends StatelessWidget {
  const _PetHeader({
    required this.nome,
    required this.especie,
    required this.idade,
    required this.badges,
  });

  final String nome;
  final String especie;
  final String idade;
  final List<String> badges;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PetVida',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.laranjaTerracota,
                ),
              ),
              const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: AppColors.laranjaSolar),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 70,
                backgroundColor: AppColors.begePata,
                child: Icon(
                  Icons.pets,
                  size: 60,
                  color: AppColors.laranjaTerracota,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final badge in badges) ...[
                    _StatusBadge(text: badge),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            nome,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.laranjaTerracota,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$especie / Idade: $idade',
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.green.shade600,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _AddVaccineButton extends StatelessWidget {
  const _AddVaccineButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.laranjaArdente,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        icon: const Icon(Icons.add),
        label: const Text(
          'ADICIONAR VACINA',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _AddVaccineDialog extends StatefulWidget {
  const _AddVaccineDialog();

  @override
  State<_AddVaccineDialog> createState() => _AddVaccineDialogState();
}

class _AddVaccineDialogState extends State<_AddVaccineDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  DateTime _dataAplicacao = DateTime.now();

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _escolherData() async {
    final selecionada = await showDatePicker(
      context: context,
      initialDate: _dataAplicacao,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (selecionada != null) {
      setState(() => _dataAplicacao = selecionada);
    }
  }

  void _handleSalvar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop({
      'nome': _nomeController.text.trim(),
      'dataAplicacao': Timestamp.fromDate(_dataAplicacao),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cremeSuave,
      title: const Text(
        'Adicionar Vacina',
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
              decoration:
                  const InputDecoration(labelText: 'Nome da vacina (ex: V10)'),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Digite o nome da vacina'
                  : null,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Data de aplicação'),
              subtitle: Text(_formatarData(_dataAplicacao)),
              trailing: const Icon(Icons.calendar_today,
                  color: AppColors.laranjaTerracota),
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

class _PetListItem extends StatelessWidget {
  const _PetListItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.begePata,
              child: Icon(icon, color: AppColors.laranjaTerracota),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _PetProfileBottomNav extends StatelessWidget {
  const _PetProfileBottomNav({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: AppColors.laranjaTerracota,
      unselectedItemColor: Colors.black45,
      onTap: (index) {
        if (index != 0) onTap();
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
    );
  }
}
