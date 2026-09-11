import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'clinics_screen.dart';
import 'login_screen.dart';
import 'meus_pets_screen.dart';
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

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _abrirTela(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  Future<void> _handleSair(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cremeSuave,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(nomeTutor: _nomeTutor, onSair: () => _handleSair(context)),
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
                      onTap: () => _abrirTela(context, const MeusPetsScreen()),
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
      bottomNavigationBar: _PetVidaBottomNav(
        onTapClinicas: () => _abrirTela(context, const ClinicsScreen()),
        onTapLinhaDoTempo: () => _abrirTela(context, const TimelineScreen()),
        onTapPerfil: () => _showSnackBar(context, 'Em breve.'),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.nomeTutor, required this.onSair});

  final String nomeTutor;
  final VoidCallback onSair;

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
              GestureDetector(
                onTap: onSair,
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
  const _Pet(this.nome, this.status, this.statusOk);
  final String nome;
  final String status;
  final bool statusOk;
}

class _PetsRow extends StatelessWidget {
  const _PetsRow({required this.onTap});

  final VoidCallback onTap;

  static const _pets = [
    _Pet('Fofo', 'Carteira Completa', true),
    _Pet('Mago', 'Próxima Vacina', false),
    _Pet('Amarelo', 'Próxima Vacina', false),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 128,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final pet in _pets) _PetCard(pet: pet),
          _AddPetCard(onTap: onTap),
        ],
      ),
    );
  }
}

class _PetCard extends StatelessWidget {
  const _PetCard({required this.pet});

  final _Pet pet;

  @override
  Widget build(BuildContext context) {
    return Container(
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
  const _ActionItem(this.label, this.icon, this.color, this.onTap);
  final String label;
  final IconData icon;
  final Color color;
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
      _ActionItem('Meus Pets', Icons.shield, AppColors.laranjaTerracota, onTapMeusPets),
      _ActionItem('Linha do Tempo', Icons.calendar_month, AppColors.amareloPorDoSol,
          onTapLinhaDoTempo),
      _ActionItem('Clínicas e Campanhas', Icons.location_on, AppColors.laranjaSolar,
          onTapClinicas),
      _ActionItem('Diário de Sintomas', Icons.assignment, AppColors.laranjaArdente,
          onTapDiario),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        for (final item in items)
          GestureDetector(
            onTap: item.onTap,
            child: Container(
              decoration: BoxDecoration(
                color: item.color,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item.icon, color: Colors.white, size: 32),
                  const SizedBox(height: 8),
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
          ),
      ],
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
