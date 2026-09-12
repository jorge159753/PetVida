import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/paw_prints_background.dart';
import '../widgets/petvida_logo.dart';
import 'clinics_screen.dart';
import 'perfil_screen.dart';

/// Linha do Tempo (ver imagens/linha do tempo.png).
class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineEvent {
  const _TimelineEvent({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.date,
    this.pet,
    this.note,
  });

  factory _TimelineEvent.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    return _TimelineEvent(
      icon: Icons.event,
      color: AppColors.laranjaTerracota,
      title: (data['titulo'] as String?) ?? 'Evento',
      subtitle: (data['subtitulo'] as String?) ?? '',
      date: (data['data'] as String?) ?? '',
      pet: data['pet'] as String?,
    );
  }

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String date;
  final String? pet;
  final String? note;
}

class _TimelineScreenState extends State<TimelineScreen> {
  static const _mockPets = ['Fofo', 'Mago', 'Amarelo', 'Bolo'];

  List<String> _petsCadastrados = [];

  List<String> get _petsDisponiveis =>
      _petsCadastrados.isNotEmpty ? _petsCadastrados : _mockPets;

  DocumentReference<Map<String, dynamic>>? get _userDocument {
    if (Firebase.apps.isEmpty) return null;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance.collection('users').doc(uid);
  }

  CollectionReference<Map<String, dynamic>>? get _eventsCollection =>
      _userDocument?.collection('eventos');

  @override
  void initState() {
    super.initState();
    _carregarPetsCadastrados();
  }

  Future<void> _carregarPetsCadastrados() async {
    final collection = _userDocument?.collection('pets');
    if (collection == null) return;
    try {
      final snapshot = await collection.get();
      final nomes = snapshot.docs
          .map((doc) => (doc.data()['nome'] as String?)?.trim())
          .whereType<String>()
          .where((nome) => nome.isNotEmpty)
          .toList();
      if (mounted && nomes.isNotEmpty) {
        setState(() => _petsCadastrados = nomes);
      }
    } catch (_) {
      // Mantém a lista de exemplo em caso de erro.
    }
  }

  final List<_TimelineEvent> _mockEvents = [
    _TimelineEvent(
      icon: Icons.vaccines,
      color: AppColors.laranjaArdente,
      title: 'Vacinação: V8 e Raiva (Mago)',
      subtitle: 'Hosp. Vet. Amigos',
      date: '12 de Out 2023',
      pet: 'Mago',
    ),
    _TimelineEvent(
      icon: Icons.medical_services,
      color: AppColors.amareloPorDoSol,
      title: 'Check-up Anual (Bolo)',
      subtitle: 'Clínica PetVida',
      date: '01 de Out 2023',
      pet: 'Bolo',
    ),
    _TimelineEvent(
      icon: Icons.home,
      color: AppColors.laranjaSolar,
      title: 'Primeiro Dia em Casa (Amarelo)',
      subtitle: '',
      date: '20 de Ago 2023',
      pet: 'Amarelo',
    ),
    _TimelineEvent(
      icon: Icons.celebration,
      color: AppColors.laranjaTerracota,
      title: 'Completou Carteira de Fofo!',
      subtitle: '',
      date: '28 de Set 2023',
      pet: 'Fofo',
      note: 'Tudo OK!',
    ),
  ];

  String? _filterPet;

  List<_TimelineEvent> _filtrar(List<_TimelineEvent> events) {
    if (_filterPet == null) return events;
    return events.where((e) => e.pet == _filterPet).toList();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleFiltros() async {
    final result = await showDialog<String?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filtrar por pet'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Todos'),
                onTap: () => Navigator.of(context).pop(null),
                leading: Icon(
                  _filterPet == null
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: AppColors.laranjaTerracota,
                ),
              ),
              for (final pet in _petsDisponiveis)
                ListTile(
                  title: Text(pet),
                  onTap: () => Navigator.of(context).pop(pet),
                  leading: Icon(
                    _filterPet == pet
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    color: AppColors.laranjaTerracota,
                  ),
                ),
            ],
          ),
        );
      },
    );
    setState(() => _filterPet = result);
  }

  Future<void> _handleNovoEvento() async {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();
    final dateController = TextEditingController();
    var selectedPet = _petsDisponiveis.first;

    final added = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Novo Evento'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(hintText: 'Título'),
                  ),
                  TextField(
                    controller: subtitleController,
                    decoration: const InputDecoration(
                      hintText: 'Local (opcional)',
                    ),
                  ),
                  TextField(
                    controller: dateController,
                    decoration: const InputDecoration(hintText: 'Data'),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: selectedPet,
                    items: [
                      for (final pet in _petsDisponiveis)
                        DropdownMenuItem(value: pet, child: Text(pet)),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => selectedPet = value);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.laranjaTerracota,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Adicionar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (added != true) return;
    if (titleController.text.trim().isEmpty) {
      _showSnackBar('Informe um título para o evento.');
      return;
    }

    final data = dateController.text.trim().isEmpty
        ? 'Hoje'
        : dateController.text.trim();
    final collection = _eventsCollection;

    if (collection == null) {
      setState(() {
        _mockEvents.insert(
          0,
          _TimelineEvent(
            icon: Icons.event,
            color: AppColors.laranjaTerracota,
            title: titleController.text.trim(),
            subtitle: subtitleController.text.trim(),
            date: data,
            pet: selectedPet,
          ),
        );
      });
      _showSnackBar('Evento adicionado!');
      return;
    }

    try {
      await collection.add({
        'titulo': titleController.text.trim(),
        'subtitulo': subtitleController.text.trim(),
        'data': data,
        'pet': selectedPet,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (mounted) _showSnackBar('Evento adicionado!');
    } catch (_) {
      if (mounted) _showSnackBar('Não foi possível adicionar o evento.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final collection = _eventsCollection;
    return Scaffold(
      backgroundColor: AppColors.cremeSuave,
      body: PawPrintsBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Header(),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          'Linha do Tempo',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.laranjaArdente,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: _handleFiltros,
                              style: OutlinedButton.styleFrom(
                                backgroundColor: AppColors.begePata,
                                foregroundColor: AppColors.laranjaTerracota,
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              icon: const Icon(Icons.tune, size: 18),
                              label: const Text('Filtros'),
                            ),
                            const Spacer(),
                            ElevatedButton.icon(
                              onPressed: _handleNovoEvento,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.laranjaTerracota,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Novo Evento'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (collection == null)
                          _EventsList(events: _filtrar(_mockEvents))
                        else
                          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: collection
                                .orderBy('createdAt', descending: true)
                                .snapshots(),
                            builder: (context, snapshot) {
                              final events = (snapshot.data?.docs ?? [])
                                  .map(_TimelineEvent.fromFirestore)
                                  .toList();
                              return _EventsList(events: _filtrar(events));
                            },
                          ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _PetVidaBottomNav(
        onTapInicio: () =>
            Navigator.of(context).popUntil((route) => route.isFirst),
        onTapClinicas: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ClinicsScreen())),
        onTapPerfil: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const PerfilScreen())),
      ),
    );
  }
}

class _EventsList extends StatelessWidget {
  const _EventsList({required this.events});

  final List<_TimelineEvent> events;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: Text('Nenhum evento encontrado.')),
      );
    }
    return Column(
      children: [
        for (var i = 0; i < events.length; i++) ...[
          _TimelineCard(event: events[i]),
          if (i != events.length - 1) const _TimelineConnector(),
        ],
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

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
              const CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: AppColors.laranjaSolar),
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
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Buscar evento',
                suffixIcon: Icon(Icons.search, color: AppColors.laranjaArdente),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({required this.event});

  final _TimelineEvent event;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.begePata,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: event.color,
            child: Icon(event.icon, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                if (event.subtitle.isNotEmpty)
                  Text(
                    event.subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                Text(
                  event.date,
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
                if (event.note != null)
                  Text(
                    event.note!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.black54,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 56,
              height: 56,
              color: Colors.white,
              child: Icon(Icons.pets, color: AppColors.laranjaSolar),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineConnector extends StatelessWidget {
  const _TimelineConnector();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 32),
      child: Container(width: 3, height: 16, color: AppColors.laranjaSolar),
    );
  }
}

class _PetVidaBottomNav extends StatelessWidget {
  const _PetVidaBottomNav({
    required this.onTapInicio,
    required this.onTapClinicas,
    required this.onTapPerfil,
  });

  final VoidCallback onTapInicio;
  final VoidCallback onTapClinicas;
  final VoidCallback onTapPerfil;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 2,
      selectedItemColor: AppColors.laranjaTerracota,
      unselectedItemColor: Colors.black45,
      onTap: (index) {
        switch (index) {
          case 0:
            onTapInicio();
          case 1:
            onTapClinicas();
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
