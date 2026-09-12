import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/paw_prints_background.dart';

/// Tela de Clínicas e Campanhas (ver imagens/Clínicas e camoanhas.png).
class ClinicsScreen extends StatefulWidget {
  const ClinicsScreen({super.key});

  @override
  State<ClinicsScreen> createState() => _ClinicsScreenState();
}

class _ClinicsScreenState extends State<ClinicsScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  static const _clinics = [
    _Clinic(
      nome: 'Clínica Veterinária Patinhas',
      endereco: 'Rua Rua - Tormotinos, 1111',
      distancia: '2.5 km',
      telefone: '(901) 336-1033',
    ),
    _Clinic(
      nome: 'Clínica Veterinária Mago',
      endereco: 'Av. Central - Tormotinos, 220',
      distancia: '3.8 km',
      telefone: '(901) 552-9021',
    ),
  ];

  static const _campaigns = [
    _Campaign(
      titulo: 'Vacinação Antirrábica 2024',
      descricao:
          'Preciação para tempo em a data de Vacinação Antirrábica 2024.',
      periodo: '08/01/2024 - 26/03/2024',
      icon: Icons.vaccines,
    ),
    _Campaign(
      titulo: 'Vacinação Antirrábica 2024',
      descricao: 'Vacinação Antirrábica de campanha de pets em ponto ativo.',
      periodo: '09/01/2024 - 26/03/2024',
      icon: Icons.pets,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  List<_Clinic> get _filteredClinics {
    if (_query.isEmpty) return _clinics;
    return _clinics
        .where((c) => c.nome.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  List<_Campaign> get _filteredCampaigns {
    if (_query.isEmpty) return _campaigns;
    return _campaigns
        .where((c) => c.titulo.toLowerCase().contains(_query.toLowerCase()))
        .toList();
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
                _Header(onVoltar: () => Navigator.of(context).maybePop()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        'Encontre os melhores cuidados\npara o seu pet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() => _query = value),
                        style: const TextStyle(color: AppColors.laranjaArdente),
                        decoration: InputDecoration(
                          hintText: 'Buscar clínicas ou campanhas...',
                          hintStyle: const TextStyle(
                            color: AppColors.laranjaArdente,
                          ),
                          suffixIcon: const Icon(
                            Icons.search,
                            color: AppColors.laranjaArdente,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: AppColors.laranjaSolar,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: AppColors.laranjaSolar,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: const BorderSide(
                              color: AppColors.laranjaTerracota,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _MapPlaceholder(clinics: _filteredClinics),
                      const SizedBox(height: 20),
                      for (final clinic in _filteredClinics)
                        _ClinicCard(
                          clinic: clinic,
                          onTap: () => _showSnackBar('Em breve.'),
                        ),
                      if (_filteredCampaigns.isNotEmpty)
                        const SizedBox(height: 8),
                      for (final campaign in _filteredCampaigns)
                        _CampaignCard(
                          campaign: campaign,
                          onSaibaMais: () => _showSnackBar('Em breve.'),
                        ),
                      if (_filteredClinics.isEmpty &&
                          _filteredCampaigns.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Text(
                              'Nenhum resultado encontrado.',
                              style: TextStyle(color: Colors.black54),
                            ),
                          ),
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
        onTap: () => _showSnackBar('Em breve.'),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onVoltar});

  final VoidCallback onVoltar;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                onTap: onVoltar,
                child: const CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.laranjaTerracota,
                  child: Icon(Icons.arrow_back, color: Colors.white, size: 20),
                ),
              ),
              const Expanded(
                child: Text(
                  'PetVida',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.laranjaTerracota,
                  ),
                ),
              ),
              const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: AppColors.laranjaSolar),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Clínicas e Campanhas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.laranjaTerracota,
            ),
          ),
        ],
      ),
    );
  }
}

class _Clinic {
  const _Clinic({
    required this.nome,
    required this.endereco,
    required this.distancia,
    required this.telefone,
  });

  final String nome;
  final String endereco;
  final String distancia;
  final String telefone;
}

class _Campaign {
  const _Campaign({
    required this.titulo,
    required this.descricao,
    required this.periodo,
    required this.icon,
  });

  final String titulo;
  final String descricao;
  final String periodo;
  final IconData icon;
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder({required this.clinics});

  final List<_Clinic> clinics;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.begePata,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.laranjaSolar, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: clinics.isEmpty
          ? const Center(
              child: Icon(
                Icons.map,
                color: AppColors.laranjaTerracota,
                size: 40,
              ),
            )
          : Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final clinic in clinics)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AppColors.laranjaTerracota,
                        size: 28,
                      ),
                      Text(
                        clinic.nome,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
    );
  }
}

class _ClinicCard extends StatelessWidget {
  const _ClinicCard({required this.clinic, required this.onTap});

  final _Clinic clinic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.laranjaSolar, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.begePata,
              child: Icon(
                Icons.local_hospital,
                color: AppColors.laranjaTerracota,
                size: 30,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    clinic.nome,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.place,
                        size: 14,
                        color: AppColors.laranjaTerracota,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          clinic.endereco,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.place,
                            size: 14,
                            color: AppColors.laranjaTerracota,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            clinic.distancia,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.phone,
                        size: 14,
                        color: AppColors.laranjaTerracota,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        clinic.telefone,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CampaignCard extends StatelessWidget {
  const _CampaignCard({required this.campaign, required this.onSaibaMais});

  final _Campaign campaign;
  final VoidCallback onSaibaMais;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.amareloPorDoSol, AppColors.laranjaSolar],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.laranjaSolar.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Icon(
              campaign.icon,
              color: AppColors.laranjaTerracota,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  campaign.titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  campaign.descricao,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      campaign.periodo,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: onSaibaMais,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.laranjaTerracota,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Saiba Mais',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PetVidaBottomNav extends StatelessWidget {
  const _PetVidaBottomNav({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 1,
      selectedItemColor: AppColors.laranjaTerracota,
      unselectedItemColor: Colors.black45,
      onTap: (index) {
        if (index != 1) onTap();
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
