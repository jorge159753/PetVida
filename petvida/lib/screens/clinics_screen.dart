import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as ll;

import '../theme/app_colors.dart';
import '../widgets/paw_prints_background.dart';
import '../widgets/petvida_logo.dart';
import 'perfil_screen.dart';
import 'timeline_screen.dart';

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
      telefone: '(11) 3456-7890',
      lat: -23.5629,
      lng: -46.6544,
    ),
    _Clinic(
      nome: 'Hospital Veterinário São Francisco',
      endereco: 'Rua das Flores, 458 - Centro',
      telefone: '(11) 2345-6789',
      lat: -23.5505,
      lng: -46.6333,
    ),
    _Clinic(
      nome: 'Clínica Pet Amigo',
      endereco: 'Rua Boa Vista, 320 - Jardim América',
      telefone: '(11) 4567-8901',
      lat: -23.5570,
      lng: -46.6396,
    ),
  ];

  ll.LatLng? _userLocation;
  String? _locationError;
  bool _loadingLocation = true;

  @override
  void initState() {
    super.initState();
    _carregarLocalizacao();
  }

  Future<void> _carregarLocalizacao() async {
    try {
      final servicoAtivo = await Geolocator.isLocationServiceEnabled();
      if (!servicoAtivo) {
        if (mounted) {
          setState(() {
            _locationError = 'Ative o GPS para ver clínicas próximas.';
            _loadingLocation = false;
          });
        }
        return;
      }

      var permissao = await Geolocator.checkPermission();
      if (permissao == LocationPermission.denied) {
        permissao = await Geolocator.requestPermission();
      }
      if (permissao == LocationPermission.denied ||
          permissao == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _locationError = 'Permissão de localização negada.';
            _loadingLocation = false;
          });
        }
        return;
      }

      final posicao = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      );
      if (mounted) {
        setState(() {
          _userLocation = ll.LatLng(posicao.latitude, posicao.longitude);
          _loadingLocation = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _locationError = 'Não foi possível obter sua localização.';
          _loadingLocation = false;
        });
      }
    }
  }

  double? _distanciaEmKm(_Clinic clinic) {
    final origem = _userLocation;
    if (origem == null) return null;
    final metros = Geolocator.distanceBetween(
      origem.latitude,
      origem.longitude,
      clinic.lat,
      clinic.lng,
    );
    return metros / 1000;
  }

  String _distanciaTexto(_Clinic clinic) {
    final km = _distanciaEmKm(clinic);
    if (km == null) return 'Distância indisponível';
    return '${km.toStringAsFixed(1)} km';
  }

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
    final filtradas = _query.isEmpty
        ? List<_Clinic>.from(_clinics)
        : _clinics
              .where((c) => c.nome.toLowerCase().contains(_query.toLowerCase()))
              .toList();
    if (_userLocation != null) {
      filtradas.sort(
        (a, b) => (_distanciaEmKm(a) ?? double.infinity).compareTo(
          _distanciaEmKm(b) ?? double.infinity,
        ),
      );
    }
    return filtradas;
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
                      _RealMap(
                        clinics: _filteredClinics,
                        userLocation: _userLocation,
                        loading: _loadingLocation,
                        errorMessage: _locationError,
                      ),
                      const SizedBox(height: 20),
                      for (final clinic in _filteredClinics)
                        _ClinicCard(
                          clinic: clinic,
                          distancia: _distanciaTexto(clinic),
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
        onTapInicio: () =>
            Navigator.of(context).popUntil((route) => route.isFirst),
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
              const Expanded(child: Center(child: PetVidaLogo(size: 64))),
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
    required this.telefone,
    required this.lat,
    required this.lng,
  });

  final String nome;
  final String endereco;
  final String telefone;
  final double lat;
  final double lng;
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

class _RealMap extends StatelessWidget {
  const _RealMap({
    required this.clinics,
    required this.userLocation,
    required this.loading,
    required this.errorMessage,
  });

  final List<_Clinic> clinics;
  final ll.LatLng? userLocation;
  final bool loading;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final center =
        userLocation ??
        (clinics.isNotEmpty
            ? ll.LatLng(clinics.first.lat, clinics.first.lng)
            : const ll.LatLng(-23.5505, -46.6333));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 190,
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
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
          child: Stack(
            children: [
              FlutterMap(
                options: MapOptions(initialCenter: center, initialZoom: 13),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.petvida.petvida',
                  ),
                  MarkerLayer(
                    markers: [
                      if (userLocation != null)
                        Marker(
                          point: userLocation!,
                          width: 36,
                          height: 36,
                          child: const Icon(
                            Icons.my_location,
                            color: Colors.blueAccent,
                            size: 30,
                          ),
                        ),
                      for (final clinic in clinics)
                        Marker(
                          point: ll.LatLng(clinic.lat, clinic.lng),
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_on,
                            color: AppColors.laranjaTerracota,
                            size: 36,
                          ),
                        ),
                    ],
                  ),
                  const RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution('© OpenStreetMap contributors'),
                    ],
                  ),
                ],
              ),
              if (loading)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.laranjaTerracota,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Icon(Icons.location_off, size: 14, color: Colors.black54),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ClinicCard extends StatelessWidget {
  const _ClinicCard({
    required this.clinic,
    required this.distancia,
    required this.onTap,
  });

  final _Clinic clinic;
  final String distancia;
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
                            distancia,
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
  const _PetVidaBottomNav({
    required this.onTapInicio,
    required this.onTapLinhaDoTempo,
    required this.onTapPerfil,
  });

  final VoidCallback onTapInicio;
  final VoidCallback onTapLinhaDoTempo;
  final VoidCallback onTapPerfil;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 1,
      selectedItemColor: AppColors.laranjaTerracota,
      unselectedItemColor: Colors.black45,
      onTap: (index) {
        switch (index) {
          case 0:
            onTapInicio();
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
