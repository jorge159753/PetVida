import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/paw_prints_background.dart';
import '../widgets/petvida_logo.dart';
import 'clinics_screen.dart';
import 'perfil_screen.dart';
import 'pet_profile_screen.dart';
import 'timeline_screen.dart';

/// Tela "Meus Pets" (ver imagens/meus pets.png).
///
/// Quando o Firebase está inicializado, os pets vêm de
/// `users/{uid}/pets` no Firestore. Sem Firebase (ex: testes de widget),
/// usa uma lista de exemplo fixa.
class MeusPetsScreen extends StatelessWidget {
  const MeusPetsScreen({super.key});

  CollectionReference<Map<String, dynamic>>? get _petsCollection {
    if (Firebase.apps.isEmpty) return null;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('pets');
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _openPerfil(BuildContext context, _Pet pet) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PetProfileScreen(
          petId: pet.id,
          nome: pet.nome,
          especie: pet.especie,
          idade: pet.idade,
          badges: pet.badgesPerfil,
        ),
      ),
    );
  }

  Future<void> _handleAdicionarPet(BuildContext context) async {
    final collection = _petsCollection;
    if (collection == null) {
      _showSnackBar(context, 'Faça login para adicionar um pet.');
      return;
    }

    final dados = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => const _AddPetDialog(),
    );
    if (dados == null) return;

    try {
      await collection.add({
        'nome': dados['nome'],
        'especie': dados['especie'],
        'idade': dados['idade'],
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (context.mounted) {
        _showSnackBar(context, 'Pet adicionado com sucesso!');
      }
    } catch (_) {
      if (context.mounted) {
        _showSnackBar(context, 'Não foi possível adicionar o pet.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final collection = _petsCollection;
    return Scaffold(
      backgroundColor: AppColors.cremeSuave,
      body: PawPrintsBackground(
        child: SafeArea(
          child: Column(
            children: [
              const _TopHeader(),
              Expanded(
                child: collection == null
                    ? _PetsList(
                        pets: _mockPets,
                        onTapAdicionar: () => _handleAdicionarPet(context),
                        onTapPet: (pet) => _openPerfil(context, pet),
                      )
                    : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: collection.orderBy('createdAt').snapshots(),
                        builder: (context, snapshot) {
                          final pets = (snapshot.data?.docs ?? [])
                              .map(_Pet.fromFirestore)
                              .toList();
                          return _PetsList(
                            pets: pets,
                            isLoading:
                                snapshot.connectionState ==
                                ConnectionState.waiting,
                            onTapAdicionar: () => _handleAdicionarPet(context),
                            onTapPet: (pet) => _openPerfil(context, pet),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _MeusPetsBottomNav(
        onTapInicio: () =>
            Navigator.of(context).popUntil((route) => route.isFirst),
        onTapClinicas: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ClinicsScreen())),
        onTapLinhaDoTempo: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const TimelineScreen())),
        onTapPerfil: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const PerfilScreen())),
      ),
    );
  }
}

class _Pet {
  const _Pet({
    this.id,
    required this.nome,
    required this.especieRaca,
    required this.statusOk,
    required this.statusAlerta,
    required this.especie,
    required this.idade,
    required this.badgesPerfil,
    this.fotoBase64,
  });

  factory _Pet.fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final nome = (data['nome'] as String?)?.trim();
    final especie = (data['especie'] as String?)?.trim();
    final idade = (data['idade'] as String?)?.trim();
    return _Pet(
      id: doc.id,
      nome: (nome == null || nome.isEmpty) ? 'Sem nome' : nome,
      especieRaca: (especie == null || especie.isEmpty)
          ? 'Não informado'
          : especie,
      statusOk: 'Cadastro Completo',
      statusAlerta: 'Sem Vacinas',
      especie: (especie == null || especie.isEmpty) ? 'Não informado' : especie,
      idade: (idade == null || idade.isEmpty) ? 'Idade não informada' : idade,
      badgesPerfil: const ['Cadastro Completo'],
      fotoBase64: data['fotoBase64'] as String?,
    );
  }

  final String? id;
  final String nome;
  final String especieRaca;
  final String statusOk;
  final String statusAlerta;
  final String especie;
  final String idade;
  final List<String> badgesPerfil;
  final String? fotoBase64;

  ImageProvider? get fotoProvider {
    final base64 = fotoBase64;
    if (base64 == null || base64.isEmpty) return null;
    try {
      return MemoryImage(base64Decode(base64));
    } catch (_) {
      return null;
    }
  }
}

const _mockPets = [
  _Pet(
    nome: 'Fofo',
    especieRaca: 'Cão / Gato',
    statusOk: 'Vacina OK',
    statusAlerta: 'Próxima Vacina',
    especie: 'Gato',
    idade: '2 anos',
    badgesPerfil: ['Vacina OK', 'Peso Ideal', 'Check-up em Dia'],
  ),
  _Pet(
    nome: 'Mago',
    especieRaca: 'Cão / Gato',
    statusOk: 'Carteira Completa',
    statusAlerta: 'Próxima Vacina',
    especie: 'Cão',
    idade: '4 anos',
    badgesPerfil: ['Vacina OK', 'Peso Ideal', 'Check-up em Dia'],
  ),
  _Pet(
    nome: 'Bolo',
    especieRaca: 'Cão / Gato',
    statusOk: 'Carteira Completa',
    statusAlerta: 'Falta Diário',
    especie: 'Gato',
    idade: '1 ano',
    badgesPerfil: ['Vacina OK', 'Peso Ideal', 'Check-up em Dia'],
  ),
  _Pet(
    nome: 'Amarelo',
    especieRaca: 'Cão / Gato',
    statusOk: 'Vacina OK',
    statusAlerta: 'Falta Diário',
    especie: 'Cão',
    idade: '3 anos',
    badgesPerfil: ['Vacina OK', 'Peso Ideal', 'Check-up em Dia'],
  ),
];

class _TopHeader extends StatelessWidget {
  const _TopHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
      child: const Row(
        children: [
          SizedBox(width: 40, height: 40),
          Expanded(child: Center(child: PetVidaLogo(size: 64))),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: AppColors.laranjaSolar),
          ),
        ],
      ),
    );
  }
}

class _PetsList extends StatelessWidget {
  const _PetsList({
    required this.pets,
    required this.onTapAdicionar,
    required this.onTapPet,
    this.isLoading = false,
  });

  final List<_Pet> pets;
  final bool isLoading;
  final VoidCallback onTapAdicionar;
  final ValueChanged<_Pet> onTapPet;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        children: [
          const Text(
            'Meus Pets',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.laranjaTerracota,
            ),
          ),
          const SizedBox(height: 24),
          if (pets.isEmpty && !isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'Nenhum pet cadastrado ainda.\nToque em "Adicionar Pet" para começar!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
            )
          else
            for (final pet in pets) ...[
              _PetListCard(pet: pet, onTap: () => onTapPet(pet)),
              const SizedBox(height: 16),
            ],
          const SizedBox(height: 8),
          _AddPetButton(onTap: onTapAdicionar),
        ],
      ),
    );
  }
}

class _PetListCard extends StatelessWidget {
  const _PetListCard({required this.pet, required this.onTap});

  final _Pet pet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.amareloPorDoSol, AppColors.begePata],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: Colors.white,
              backgroundImage: pet.fotoProvider,
              child: pet.fotoProvider == null
                  ? const Icon(
                      Icons.pets,
                      size: 32,
                      color: AppColors.laranjaTerracota,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.nome,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.laranjaTerracota,
                    ),
                  ),
                  Text(
                    pet.especieRaca,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _StatusBadge(text: pet.statusOk, color: Colors.green.shade600),
                const SizedBox(height: 8),
                _StatusBadge(
                  text: pet.statusAlerta,
                  color: Colors.red.shade400,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _AddPetButton extends StatelessWidget {
  const _AddPetButton({required this.onTap});

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
          'Adicionar Pet',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _AddPetDialog extends StatefulWidget {
  const _AddPetDialog();

  @override
  State<_AddPetDialog> createState() => _AddPetDialogState();
}

class _AddPetDialogState extends State<_AddPetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _especieController = TextEditingController();
  final _idadeController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _especieController.dispose();
    _idadeController.dispose();
    super.dispose();
  }

  void _handleSalvar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop({
      'nome': _nomeController.text.trim(),
      'especie': _especieController.text.trim(),
      'idade': _idadeController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cremeSuave,
      title: const Text(
        'Adicionar Pet',
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
              decoration: const InputDecoration(labelText: 'Nome'),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Digite o nome do pet'
                  : null,
            ),
            TextFormField(
              controller: _especieController,
              decoration: const InputDecoration(
                labelText: 'Espécie (ex: Cão, Gato)',
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Digite a espécie'
                  : null,
            ),
            TextFormField(
              controller: _idadeController,
              decoration: const InputDecoration(
                labelText: 'Idade (ex: 2 anos)',
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

class _MeusPetsBottomNav extends StatelessWidget {
  const _MeusPetsBottomNav({
    required this.onTapInicio,
    required this.onTapClinicas,
    required this.onTapLinhaDoTempo,
    required this.onTapPerfil,
  });

  final VoidCallback onTapInicio;
  final VoidCallback onTapClinicas;
  final VoidCallback onTapLinhaDoTempo;
  final VoidCallback onTapPerfil;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: AppColors.laranjaTerracota,
      unselectedItemColor: Colors.black45,
      onTap: (index) {
        switch (index) {
          case 0:
            onTapInicio();
          case 1:
            onTapClinicas();
          case 2:
            onTapLinhaDoTempo();
          case 3:
            onTapPerfil();
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
    );
  }
}
