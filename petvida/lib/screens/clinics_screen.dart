import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      nome: 'Clínica Veterinária Vida Animal',
      endereco: 'Av. Paulista, 1200 - Bela Vista',
      distancia: '1.2 km',
      telefone: '(11) 3456-7890',
    ),
    _Clinic(
      nome: 'Hospital Veterinário São Francisco',
      endereco: 'Rua das Flores, 458 - Centro',
      distancia: '2.8 km',
      telefone: '(11) 2345-6789',
    ),
    _Clinic(
      nome: 'Clínica Pet Amigo',
      endereco: 'Rua Boa Vista, 320 - Jardim América',
      distancia: '3.5 km',
      telefone: '(11) 4567-8901',
    ),
  ];

  static const _campaigns = [
    _Campaign(
      titulo: 'Vacinação Antirrábica 2026',
      descricao:
          'Campanha gratuita de vacinação contra raiva para cães e gatos, '
          'promovida pela Secretaria Municipal de Saúde. Leve seu pet a '
          'qualquer ponto de apoio, sem necessidade de agendamento.',
      periodo: '15/03/2026 - 30/04/2026',
      icon: Icons.vaccines,
    ),
    _Campaign(
      titulo: 'Mutirão de Castração',
      descricao:
          'Castração gratuita para cães e gatos de famílias de baixa renda. '
          'Vagas limitadas e inscrição prévia necessária na clínica mais '
          'próxima.',
      periodo: '01/05/2026 - 31/05/2026',
      icon: Icons.medical_services,
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

  Future<void> _handleClinicTap(_Clinic clinic) async {
    await Clipboard.setData(
      ClipboardData(
        text: '${clinic.nome}\n${clinic.endereco}\nTel: ${clinic.telefone}',
      ),
    );
    if (mounted) _showSnackBar('Informações da clínica copiadas!');
  }

  void _handleSaibaMais(_Campaign campaign) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cremeSuave,
        title: Text(
          campaign.titulo,
          style: const TextStyle(
            color: AppColors.laranjaTerracota,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(campaign.descricao),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: AppColors.laranjaTerracota,
                ),
                const SizedBox(width: 6),
                Text(
                  campaign.periodo,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
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
                          fontSize: 20,
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
                          onTap: () => _handleClinicTap(clinic),
                        ),
                      if (_filteredCampaigns.isNotEmpty)
                        const SizedBox(height: 8),
                      for (final campaign in _filteredCampaigns)
                        _CampaignCard(
                          campaign: campaign,
                          onSaibaMais: () => _handleSaibaMais(campaign),
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

  static const _pinSlots = [
    Alignment(-0.7, -0.55),
    Alignment(0.05, -0.75),
    Alignment(0.7, -0.15),
    Alignment(-0.2, 0.4),
    Alignment(0.6, 0.65),
    Alignment(-0.75, 0.75),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
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
          : Stack(
              children: [
                const Positioned.fill(child: _MapStreets()),
                for (var i = 0; i < clinics.length; i++)
                  Align(
                    alignment: _pinSlots[i % _pinSlots.length],
                    child: _MapPin(clinic: clinics[i], emphasized: i == 0),
                  ),
              ],
            ),
    );
  }
}

class _MapStreets extends StatelessWidget {
  const _MapStreets();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 22,
          left: -20,
          right: -20,
          child: Transform.rotate(
            angle: -0.07,
            child: Container(height: 10, color: AppColors.begePata),
          ),
        ),
        Positioned(
          top: 110,
          left: -20,
          right: -20,
          child: Transform.rotate(
            angle: 0.05,
            child: Container(height: 8, color: AppColors.begePata),
          ),
        ),
        Positioned(
          top: -20,
          bottom: -20,
          left: 70,
          child: Transform.rotate(
            angle: 0.1,
            child: Container(width: 8, color: AppColors.begePata),
          ),
        ),
        Positioned(
          top: -20,
          bottom: -20,
          right: 90,
          child: Container(width: 6, color: AppColors.begePata),
        ),
        Positioned(
          top: 34,
          left: 24,
          child: Container(
            width: 60,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.amareloPorDoSol.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        Positioned(
          bottom: 24,
          right: 34,
          child: Container(
            width: 48,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.laranjaSolar.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ],
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin({required this.clinic, required this.emphasized});

  final _Clinic clinic;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(emphasized ? 7 : 5),
          decoration: BoxDecoration(
            color: emphasized
                ? AppColors.laranjaTerracota
                : AppColors.laranjaSolar,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.add_location_alt,
            color: Colors.white,
            size: emphasized ? 18 : 14,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          constraints: const BoxConstraints(maxWidth: 92),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            clinic.nome,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ],
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
        padding: const EdgeInsets.all(14),
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
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.begePata,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.local_hospital,
                color: AppColors.laranjaTerracota,
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    clinic.nome,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.place,
                        size: 15,
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.place,
                            size: 15,
                            color: AppColors.laranjaTerracota,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            clinic.distancia,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.phone,
                        size: 15,
                        color: AppColors.laranjaTerracota,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        clinic.telefone,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.amareloPorDoSol, AppColors.laranjaSolar],
        ),
        borderRadius: BorderRadius.circular(22),
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
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  campaign.titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  campaign.descricao,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        campaign.periodo,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
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
