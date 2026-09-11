import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Tela de perfil do pet (ver imagens/perfil pet.png).
class PetProfileScreen extends StatelessWidget {
  const PetProfileScreen({
    super.key,
    this.nome = 'Fofo',
    this.especie = 'Gato',
    this.idade = '2 anos',
    this.badges = const ['Vacina OK', 'Peso Ideal', 'Check-up em Dia'],
  });

  final String nome;
  final String especie;
  final String idade;
  final List<String> badges;

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
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
                      onTap: () => _showSnackBar(context, 'Em breve.'),
                    ),
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
