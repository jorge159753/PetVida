import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/paw_prints_background.dart';
import '../widgets/petvida_logo.dart';
import 'clinics_screen.dart';
import 'meus_pets_screen.dart';
import 'perfil_screen.dart';
import 'pet_profile_screen.dart';
import 'symptom_diary_screen.dart';
import 'timeline_screen.dart';

/// Tela inicial (ver imagens/tela inicial.png).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String get _nomeTutor {
    try {
      final email = FirebaseAuth.instance.currentUser?.email;
      if (email == null || email.isEmpty) return 'Tutor';
      return email.split('@').first;
    } catch (_) {
      return 'Tutor';
    }
  }

  void _abrirTela(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cremeSuave,
      body: PawPrintsBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Header(
                  nomeTutor: _nomeTutor,
                  onPerfil: () => _abrirTela(context, const PerfilScreen()),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Text(
                        'Olá, $_nomeTutor!',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const Text(
                        'Bem-vindo(a) ao PetVida!',
                        style: TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                      const SizedBox(height: 20),
                      _PetsRow(
                        onTapAdicionar: () =>
                            _abrirTela(context, const MeusPetsScreen()),
                        onTapPet: (pet) => _abrirTela(
                          context,
                          PetProfileScreen(
                            petId: pet.id,
                            nome: pet.nome,
                            especie: pet.especie,
                            idade: pet.idade,
                            badges: const ['Cadastro Completo'],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _ActionGrid(
                        onTapMeusPets: () =>
                            _abrirTela(context, const MeusPetsScreen()),
                        onTapLinhaDoTempo: () =>
                            _abrirTela(context, const TimelineScreen()),
                        onTapClinicas: () =>
                            _abrirTela(context, const ClinicsScreen()),
                        onTapDiario: () =>
                            _abrirTela(context, const SymptomDiaryScreen()),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _PetVidaBottomNav(
        onTapClinicas: () => _abrirTela(context, const ClinicsScreen()),
        onTapLinhaDoTempo: () => _abrirTela(context, const TimelineScreen()),
        onTapPerfil: () => _abrirTela(context, const PerfilScreen()),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.nomeTutor, required this.onPerfil});

  final String nomeTutor;
  final VoidCallback onPerfil;

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
              const PetVidaWordmark(),
              GestureDetector(
                onTap: onPerfil,
                child: const CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, color: AppColors.laranjaSolar),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const TextField(
              enabled: false,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Buscar',
                suffixIcon: Icon(Icons.search, color: AppColors.laranjaArdente),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pet {
  const _Pet(
    this.nome,
    this.status,
    this.statusOk, {
    this.id,
    this.especie = 'Não informado',
    this.idade = 'Idade não informada',
  });

  factory _Pet.fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final nome = (data['nome'] as String?)?.trim();
    final especie = (data['especie'] as String?)?.trim();
    final idade = (data['idade'] as String?)?.trim();
    return _Pet(
      (nome == null || nome.isEmpty) ? 'Sem nome' : nome,
      'Sem Vacinas',
      false,
      id: doc.id,
      especie: (especie == null || especie.isEmpty) ? 'Não informado' : especie,
      idade: (idade == null || idade.isEmpty) ? 'Idade não informada' : idade,
    );
  }

  final String? id;
  final String nome;
  final String status;
  final bool statusOk;
  final String especie;
  final String idade;
}

class _PetsRow extends StatelessWidget {
  const _PetsRow({required this.onTapAdicionar, required this.onTapPet});

  final VoidCallback onTapAdicionar;
  final ValueChanged<_Pet> onTapPet;

  static const _mockPets = [
    _Pet('Fofo', 'Carteira Completa', true),
    _Pet('Mago', 'Próxima Vacina', false),
    _Pet('Amarelo', 'Próxima Vacina', false),
  ];

  CollectionReference<Map<String, dynamic>>? get _petsCollection {
    if (Firebase.apps.isEmpty) return null;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('pets');
  }

  @override
  Widget build(BuildContext context) {
    final collection = _petsCollection;
    if (collection == null) {
      return _PetsList(
        pets: _mockPets,
        onTapAdicionar: onTapAdicionar,
        onTapPet: onTapPet,
      );
    }
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: collection.orderBy('createdAt').snapshots(),
      builder: (context, snapshot) {
        final pets = (snapshot.data?.docs ?? [])
            .map(_Pet.fromFirestore)
            .toList();
        return _PetsList(
          pets: pets,
          onTapAdicionar: onTapAdicionar,
          onTapPet: onTapPet,
        );
      },
    );
  }
}

class _PetsList extends StatelessWidget {
  const _PetsList({
    required this.pets,
    required this.onTapAdicionar,
    required this.onTapPet,
  });

  final List<_Pet> pets;
  final VoidCallback onTapAdicionar;
  final ValueChanged<_Pet> onTapPet;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 128,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final pet in pets)
            _PetCard(pet: pet, onTap: () => onTapPet(pet)),
          _AddPetCard(onTap: onTapAdicionar),
        ],
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  const _PetCard({required this.pet, required this.onTap});

  final _Pet pet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 88,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.laranjaSolar, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.begePata,
              child: Icon(Icons.pets, color: AppColors.laranjaTerracota),
            ),
            const SizedBox(height: 6),
            Text(
              pet.nome,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Container(
              height: 4,
              width: 60,
              decoration: BoxDecoration(
                color: pet.statusOk ? Colors.green : AppColors.laranjaTerracota,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddPetCard extends StatelessWidget {
  const _AddPetCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 88,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.laranjaTerracota,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Colors.white, size: 28),
            SizedBox(height: 6),
            Text(
              'Adicionar Pet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionItem {
  const _ActionItem({
    required this.label,
    required this.iconAsset,
    required this.gradient,
    required this.onTap,
  });

  final String label;
  final String iconAsset;
  final List<Color> gradient;
  final VoidCallback onTap;
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid({
    required this.onTapMeusPets,
    required this.onTapLinhaDoTempo,
    required this.onTapClinicas,
    required this.onTapDiario,
  });

  final VoidCallback onTapMeusPets;
  final VoidCallback onTapLinhaDoTempo;
  final VoidCallback onTapClinicas;
  final VoidCallback onTapDiario;

  @override
  Widget build(BuildContext context) {
    final items = [
      _ActionItem(
        label: 'Meus Pets',
        iconAsset: 'assets/icons/actions/meus_pets.png',
        gradient: const [AppColors.laranjaTerracota, AppColors.laranjaArdente],
        onTap: onTapMeusPets,
      ),
      _ActionItem(
        label: 'Linha do Tempo',
        iconAsset: 'assets/icons/actions/linha_do_tempo.png',
        gradient: const [AppColors.amareloPorDoSol, AppColors.laranjaSolar],
        onTap: onTapLinhaDoTempo,
      ),
      _ActionItem(
        label: 'Clínicas e Campanhas',
        iconAsset: 'assets/icons/actions/clinicas_campanhas.png',
        gradient: const [AppColors.laranjaSolar, AppColors.amareloPorDoSol],
        onTap: onTapClinicas,
      ),
      _ActionItem(
        label: 'Diário de Sintomas',
        iconAsset: 'assets/icons/actions/diario_sintomas.png',
        gradient: const [AppColors.laranjaSolar, AppColors.laranjaArdente],
        onTap: onTapDiario,
      ),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.15,
      children: [for (final item in items) _ActionCard(item: item)],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.item});

  final _ActionItem item;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: item.gradient,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: item.gradient.last.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(item.iconAsset, width: 56, height: 56),
            const SizedBox(height: 10),
            Text(
              item.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PetVidaBottomNav extends StatelessWidget {
  const _PetVidaBottomNav({
    required this.onTapClinicas,
    required this.onTapLinhaDoTempo,
    required this.onTapPerfil,
  });

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
