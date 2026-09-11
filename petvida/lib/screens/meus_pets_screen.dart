import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'pet_profile_screen.dart';

/// Tela "Meus Pets" (ver imagens/meus pets.png).
class MeusPetsScreen extends StatelessWidget {
  const MeusPetsScreen({super.key});

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _openPerfil(BuildContext context, _Pet pet) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PetProfileScreen(
          nome: pet.nome,
          especie: pet.especie,
          idade: pet.idade,
          badges: pet.badgesPerfil,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cremeSuave,
      body: SafeArea(
        child: Column(
          children: [
            _TopHeader(),
            Expanded(
              child: SingleChildScrollView(
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
                    for (final pet in _pets) ...[
                      _PetListCard(
                        pet: pet,
                        onTap: () => _openPerfil(context, pet),
                      ),
                      const SizedBox(height: 16),
                    ],
                    const SizedBox(height: 8),
                    _AddPetButton(
                      onTap: () => _showSnackBar(context, 'Em breve.'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _MeusPetsBottomNav(
        onTap: () => _showSnackBar(context, 'Em breve.'),
      ),
    );
  }
}

class _Pet {
  const _Pet({
    required this.nome,
    required this.especieRaca,
    required this.statusOk,
    required this.statusAlerta,
    required this.especie,
    required this.idade,
    required this.badgesPerfil,
  });

  final String nome;
  final String especieRaca;
  final String statusOk;
  final String statusAlerta;
  final String especie;
  final String idade;
  final List<String> badgesPerfil;
}

const _pets = [
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
      child: Row(
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
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 36,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.pets,
                size: 32,
                color: AppColors.laranjaTerracota,
              ),
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

class _MeusPetsBottomNav extends StatelessWidget {
  const _MeusPetsBottomNav({required this.onTap});

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
