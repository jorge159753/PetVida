import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
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
  final _mapController = MapController();
  String _query = '';

  /// Clínicas veterinárias reais próximas do usuário, buscadas na Overpass
  /// API (OpenStreetMap) a partir da localização atual. Não há mais dados
  /// fixos/mocados de São Paulo.
  List<_Clinic> _clinics = [];
  bool _loadingClinics = false;
  String? _clinicsError;

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

      // Mostra rapidamente a última localização conhecida pelo aparelho
      // (quase instantânea) enquanto uma localização fresca é obtida, para
      // o mapa não ficar parado no centro padrão durante a espera do GPS.
      final ultimaConhecida = await Geolocator.getLastKnownPosition();
      if (ultimaConhecida != null && mounted) {
        setState(() {
          _userLocation = ll.LatLng(
            ultimaConhecida.latitude,
            ultimaConhecida.longitude,
          );
        });
        _atualizarCameraDoMapa();
      }

      Position posicao;
      try {
        posicao = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 12),
          ),
        );
      } on TimeoutException {
        // Sem sinal de GPS suficiente a tempo: fica com a última localização
        // conhecida (se houver) em vez de travar o carregamento pra sempre.
        if (ultimaConhecida == null) rethrow;
        if (mounted) setState(() => _loadingLocation = false);
        unawaited(
          _buscarClinicasProximas(
            ultimaConhecida.latitude,
            ultimaConhecida.longitude,
          ),
        );
        return;
      }

      if (mounted) {
        setState(() {
          _userLocation = ll.LatLng(posicao.latitude, posicao.longitude);
          _loadingLocation = false;
        });
        _atualizarCameraDoMapa();
        unawaited(
          _buscarClinicasProximas(posicao.latitude, posicao.longitude),
        );
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

  /// Instâncias públicas da Overpass API (todas gratuitas, sem chave).
  /// Tentamos mais de uma porque a instância principal é conhecida por
  /// ficar sobrecarregada/limitar requisições anônimas.
  static const _overpassEndpoints = [
    'https://overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
    'https://overpass.openstreetmap.ru/api/interpreter',
  ];

  /// Busca clínicas veterinárias reais num raio de 8 km da localização do
  /// usuário usando a Overpass API (dados livres do OpenStreetMap, sem
  /// necessidade de chave/API paga).
  Future<void> _buscarClinicasProximas(double lat, double lng) async {
    if (mounted) {
      setState(() {
        _loadingClinics = true;
        _clinicsError = null;
      });
    }

    final query =
        '[out:json][timeout:25];'
        '('
        'node["amenity"="veterinary"](around:8000,$lat,$lng);'
        'way["amenity"="veterinary"](around:8000,$lat,$lng);'
        'relation["amenity"="veterinary"](around:8000,$lat,$lng);'
        ');'
        'out center 30;';

    Object? ultimoErro;

    for (final endpoint in _overpassEndpoints) {
      try {
        final resposta = await http
            .post(Uri.parse(endpoint), body: {'data': query})
            .timeout(const Duration(seconds: 25));

        if (resposta.statusCode != 200) {
          throw Exception('$endpoint respondeu ${resposta.statusCode}');
        }

        final corpo = jsonDecode(resposta.body) as Map<String, dynamic>;
        final elementos = corpo['elements'] as List<dynamic>? ?? [];
        final clinicas = <_Clinic>[];

        for (final elemento in elementos) {
          final item = elemento as Map<String, dynamic>;
          final tags = (item['tags'] as Map<String, dynamic>?) ?? {};
          final center = item['center'] as Map<String, dynamic>?;
          final clinicLat =
              (item['lat'] as num?)?.toDouble() ??
              (center?['lat'] as num?)?.toDouble();
          final clinicLng =
              (item['lon'] as num?)?.toDouble() ??
              (center?['lon'] as num?)?.toDouble();
          if (clinicLat == null || clinicLng == null) continue;

          final rua = tags['addr:street'] as String?;
          final numero = tags['addr:housenumber'] as String?;
          final bairro = tags['addr:suburb'] as String?;
          final partesEndereco = [
            if (rua != null) (numero != null ? '$rua, $numero' : rua),
            ?bairro,
          ];

          clinicas.add(
            _Clinic(
              nome: (tags['name'] as String?) ?? 'Clínica Veterinária',
              endereco: partesEndereco.isEmpty
                  ? 'Endereço não informado'
                  : partesEndereco.join(' - '),
              telefone:
                  (tags['phone'] as String?) ??
                  (tags['contact:phone'] as String?) ??
                  'Telefone não informado',
              lat: clinicLat,
              lng: clinicLng,
            ),
          );
        }

        if (mounted) {
          setState(() {
            _clinics = clinicas;
            _loadingClinics = false;
          });
          _atualizarCameraDoMapa();
        }
        return;
      } catch (e) {
        ultimoErro = e;
        // Tenta o próximo espelho da Overpass API antes de desistir.
      }
    }

    debugPrint('Falha ao buscar clínicas na Overpass API: $ultimoErro');
    if (mounted) {
      setState(() {
        _clinicsError =
            'Não foi possível buscar clínicas próximas. '
            'Verifique sua conexão com a internet e tente novamente.';
        _loadingClinics = false;
      });
    }
  }

  /// Move a câmera do mapa para refletir a localização real do usuário e/ou
  /// o resultado da busca atual, em vez de depender de `initialCenter`
  /// (que o flutter_map só aplica na primeira renderização do mapa).
  void _atualizarCameraDoMapa() {
    final clinicasFiltradas = _filteredClinics;
    final pontos = <ll.LatLng>[
      ?_userLocation,
      for (final clinic in clinicasFiltradas) ll.LatLng(clinic.lat, clinic.lng),
    ];

    if (pontos.isEmpty) return;

    if (pontos.length == 1) {
      _mapController.move(pontos.first, 15);
      return;
    }

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(pontos),
        padding: const EdgeInsets.fromLTRB(30, 30, 30, 30),
      ),
    );
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
    _mapController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleTentarNovamenteClinicas() {
    final location = _userLocation;
    if (location == null) {
      _carregarLocalizacao();
      return;
    }
    _buscarClinicasProximas(location.latitude, location.longitude);
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
                        onChanged: (value) {
                          setState(() => _query = value);
                          _atualizarCameraDoMapa();
                        },
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
                        mapController: _mapController,
                        clinics: _filteredClinics,
                        userLocation: _userLocation,
                        loading: _loadingLocation || _loadingClinics,
                        errorMessage: _locationError,
                      ),
                      const SizedBox(height: 20),
                      if (_loadingClinics)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.laranjaTerracota,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Buscando clínicas perto de você...',
                                style: TextStyle(color: Colors.black54),
                              ),
                            ],
                          ),
                        )
                      else if (_clinicsError != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.wifi_off,
                                size: 18,
                                color: Colors.black54,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _clinicsError!,
                                  style: const TextStyle(
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: _handleTentarNovamenteClinicas,
                                child: const Text('Tentar novamente'),
                              ),
                            ],
                          ),
                        )
                      else if (_userLocation != null &&
                          _clinics.isEmpty &&
                          _query.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'Nenhuma clínica veterinária encontrada num raio de 8 km.',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
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
              const SizedBox(width: 36, height: 36),
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
    required this.mapController,
    required this.clinics,
    required this.userLocation,
    required this.loading,
    required this.errorMessage,
  });

  final MapController mapController;
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
                mapController: mapController,
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
