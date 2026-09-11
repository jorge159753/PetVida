import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

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

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String date;
  final String? pet;
  final String? note;
}

class _TimelineScreenState extends State<TimelineScreen> {
  static const _pets = ['Fofo', 'Mago', 'Amarelo', 'Bolo'];

  final List<_TimelineEvent> _events = const [
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
  ].toList();

  String? _filterPet;

  List<_TimelineEvent> get _filteredEvents {
    if (_filterPet == null) return _events;
    return _events.where((e) => e.pet == _filterPet).toList();
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
              for (final pet in _pets)
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
    var selectedPet = _pets.first;

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
                    decoration:
                        const InputDecoration(hintText: 'Local (opcional)'),
                  ),
                  TextField(
                    controller: dateController,
                    decoration: const InputDecoration(hintText: 'Data'),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: selectedPet,
                    items: [
                      for (final pet in _pets)
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

    setState(() {
      _events.insert(
        0,
        _TimelineEvent(
          icon: Icons.event,
          color: AppColors.laranjaTerracota,
          title: titleController.text.trim(),
          subtitle: subtitleController.text.trim(),
          date: dateController.text.trim().isEmpty
              ? 'Hoje'
              : dateController.text.trim(),
          pet: selectedPet,
        ),
      );
    });
    _showSnackBar('Evento adicionado!');
  }

  @override
  Widget build(BuildContext context) {
    final events = _filteredEvents;
    return Scaffold(
      backgroundColor: AppColors.cremeSuave,
      body: SafeArea(
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
                      if (events.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Text('Nenhum evento encontrado.'),
                          ),
                        )
                      else
                        for (var i = 0; i < events.length; i++) ...[
                          _TimelineCard(event: events[i]),
                          if (i != events.length - 1)
                            const _TimelineConnector(),
                        ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _PetVidaBottomNav(
        onTap: () => _showSnackBar('Em breve.'),
      ),
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
      child: Container(
        width: 3,
        height: 16,
        color: AppColors.laranjaSolar,
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
      currentIndex: 2,
      selectedItemColor: AppColors.laranjaTerracota,
      unselectedItemColor: Colors.black45,
      onTap: (index) {
        if (index != 2) onTap();
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
