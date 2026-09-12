import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../widgets/paw_prints_background.dart';
import '../widgets/petvida_logo.dart';
import 'clinics_screen.dart';
import 'perfil_screen.dart';
import 'timeline_screen.dart';

/// Diário de Sintomas (ver imagens/diário de sintomas.png).
class SymptomDiaryScreen extends StatefulWidget {
  const SymptomDiaryScreen({super.key});

  @override
  State<SymptomDiaryScreen> createState() => _SymptomDiaryScreenState();
}

class _Symptom {
  const _Symptom(this.label, this.icon);
  final String label;
  final IconData icon;
}

class _SymptomRecord {
  const _SymptomRecord({
    required this.date,
    required this.symptom,
    required this.severity,
    required this.pet,
  });

  factory _SymptomRecord.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final timestamp = data['data'] as Timestamp?;
    return _SymptomRecord(
      date: timestamp == null
          ? 'Data não informada'
          : _formatarDataCurta(timestamp.toDate()),
      symptom: (data['sintoma'] as String?) ?? 'Sintoma',
      severity: _severidadeFromLabel(data['severidade'] as String?),
      pet: (data['pet'] as String?) ?? 'Pet',
    );
  }

  final String date;
  final String symptom;
  final _Severity severity;
  final String pet;
}

const _meses = [
  'Jan',
  'Fev',
  'Mar',
  'Abr',
  'Mai',
  'Jun',
  'Jul',
  'Ago',
  'Set',
  'Out',
  'Nov',
  'Dez',
];

String _formatarDataCurta(DateTime data) {
  final agora = DateTime.now();
  final texto =
      '${data.day.toString().padLeft(2, '0')} de ${_meses[data.month - 1]}';
  final mesmoDia =
      data.year == agora.year &&
      data.month == agora.month &&
      data.day == agora.day;
  return mesmoDia ? '$texto (Hoje)' : texto;
}

enum _Severity { baixo, medio, alto }

extension on _Severity {
  String get label {
    switch (this) {
      case _Severity.baixo:
        return 'Baixo';
      case _Severity.medio:
        return 'Médio';
      case _Severity.alto:
        return 'Alto';
    }
  }

  Color get color {
    switch (this) {
      case _Severity.baixo:
        return Colors.green;
      case _Severity.medio:
        return AppColors.amareloPorDoSol;
      case _Severity.alto:
        return Colors.red;
    }
  }
}

_Severity _severidadeFromLabel(String? label) {
  switch (label) {
    case 'Baixo':
      return _Severity.baixo;
    case 'Alto':
      return _Severity.alto;
    default:
      return _Severity.medio;
  }
}

class _SymptomDiaryScreenState extends State<SymptomDiaryScreen> {
  static const _symptoms = [
    _Symptom('Febre', Icons.thermostat),
    _Symptom('Apetite', Icons.restaurant),
    _Symptom('Letargia', Icons.bedtime),
    _Symptom('Vômito', Icons.sick),
    _Symptom('Tosse', Icons.air),
  ];

  static const _mockPets = ['Fofo', 'Mago', 'Amarelo'];

  final _notesController = TextEditingController();

  int? _selectedSymptomIndex;
  double _severityValue = 1;
  String _selectedPet = _mockPets.first;
  List<String> _petsCadastrados = [];

  final List<_SymptomRecord> _mockRecords = [
    _SymptomRecord(
      date: '12 de Out (Hoje)',
      symptom: 'Letargia',
      severity: _Severity.medio,
      pet: 'Mago',
    ),
    _SymptomRecord(
      date: '10 de Out',
      symptom: 'Vômito',
      severity: _Severity.alto,
      pet: 'Fofo',
    ),
    _SymptomRecord(
      date: '08 de Out',
      symptom: 'Apetite',
      severity: _Severity.baixo,
      pet: 'Amarelo',
    ),
    _SymptomRecord(
      date: '05 de Out',
      symptom: 'Febre',
      severity: _Severity.medio,
      pet: 'Bolo',
    ),
  ];

  DocumentReference<Map<String, dynamic>>? get _userDocument {
    if (Firebase.apps.isEmpty) return null;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance.collection('users').doc(uid);
  }

  CollectionReference<Map<String, dynamic>>? get _symptomsCollection =>
      _userDocument?.collection('sintomas');

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
        setState(() {
          _petsCadastrados = nomes;
          _selectedPet = nomes.first;
        });
      }
    } catch (_) {
      // Mantém a lista de exemplo em caso de erro.
    }
  }

  List<String> get _petsDisponiveis =>
      _petsCadastrados.isNotEmpty ? _petsCadastrados : _mockPets;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  _Severity get _currentSeverity {
    if (_severityValue < 0.5) return _Severity.baixo;
    if (_severityValue < 1.5) return _Severity.medio;
    return _Severity.alto;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleAdicionarRegistro() async {
    if (_selectedSymptomIndex == null) {
      _showSnackBar('Selecione um sintoma.');
      return;
    }

    final symptom = _symptoms[_selectedSymptomIndex!];
    final collection = _symptomsCollection;

    if (collection == null) {
      setState(() {
        _mockRecords.insert(
          0,
          _SymptomRecord(
            date: 'Hoje',
            symptom: symptom.label,
            severity: _currentSeverity,
            pet: _selectedPet,
          ),
        );
        _selectedSymptomIndex = null;
        _severityValue = 1;
        _notesController.clear();
      });
      _showSnackBar('Registro de sintoma adicionado!');
      return;
    }

    try {
      await collection.add({
        'sintoma': symptom.label,
        'severidade': _currentSeverity.label,
        'pet': _selectedPet,
        'anotacoes': _notesController.text.trim(),
        'data': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        setState(() {
          _selectedSymptomIndex = null;
          _severityValue = 1;
          _notesController.clear();
        });
        _showSnackBar('Registro de sintoma adicionado!');
      }
    } catch (_) {
      if (mounted) {
        _showSnackBar('Não foi possível adicionar o registro.');
      }
    }
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
                const _Header(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      const Row(
                        children: [
                          Text(
                            'Diário de Sintomas',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.laranjaArdente,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.assignment,
                            color: AppColors.laranjaArdente,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SymptomIconsRow(
                        symptoms: _symptoms,
                        selectedIndex: _selectedSymptomIndex,
                        onSelect: (index) {
                          setState(() => _selectedSymptomIndex = index);
                        },
                      ),
                      const SizedBox(height: 16),
                      _SeverityAndNotesCard(
                        severityValue: _severityValue,
                        onSeverityChanged: (value) {
                          setState(() => _severityValue = value);
                        },
                        notesController: _notesController,
                        selectedPet: _selectedPet,
                        pets: _petsDisponiveis,
                        onPetChanged: (pet) {
                          if (pet != null) setState(() => _selectedPet = pet);
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Histórico de Registros',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.laranjaTerracota,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (_symptomsCollection == null)
                        _RecordsHistory(records: _mockRecords)
                      else
                        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: _symptomsCollection!
                              .orderBy('data', descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            final records = (snapshot.data?.docs ?? [])
                                .map(_SymptomRecord.fromFirestore)
                                .toList();
                            return _RecordsHistory(records: records);
                          },
                        ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _handleAdicionarRegistro,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.laranjaTerracota,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text(
                            'Adicionar Novo Registro de Sintoma',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
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
        onTapClinicas: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ClinicsScreen())),
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
      child: const Row(
        children: [
          SizedBox(width: 40, height: 40),
          Expanded(child: Center(child: PetVidaLogo(size: 64))),
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: AppColors.laranjaSolar),
          ),
        ],
      ),
    );
  }
}

class _SymptomIconsRow extends StatelessWidget {
  const _SymptomIconsRow({
    required this.symptoms,
    required this.selectedIndex,
    required this.onSelect,
  });

  final List<_Symptom> symptoms;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.begePata,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (var i = 0; i < symptoms.length; i++)
            _SymptomIcon(
              symptom: symptoms[i],
              selected: selectedIndex == i,
              onTap: () => onSelect(i),
            ),
        ],
      ),
    );
  }
}

class _SymptomIcon extends StatelessWidget {
  const _SymptomIcon({
    required this.symptom,
    required this.selected,
    required this.onTap,
  });

  final _Symptom symptom;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: selected ? AppColors.laranjaSolar : Colors.white,
            child: Icon(
              symptom.icon,
              color: selected ? Colors.white : AppColors.laranjaTerracota,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            symptom.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: AppColors.laranjaTerracota,
            ),
          ),
        ],
      ),
    );
  }
}

class _SeverityAndNotesCard extends StatelessWidget {
  const _SeverityAndNotesCard({
    required this.severityValue,
    required this.onSeverityChanged,
    required this.notesController,
    required this.selectedPet,
    required this.pets,
    required this.onPetChanged,
  });

  final double severityValue;
  final ValueChanged<double> onSeverityChanged;
  final TextEditingController notesController;
  final String selectedPet;
  final List<String> pets;
  final ValueChanged<String?> onPetChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.laranjaTerracota, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Severidade do Sintoma',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  gradient: const LinearGradient(
                    colors: [
                      Colors.green,
                      AppColors.amareloPorDoSol,
                      Colors.red,
                    ],
                  ),
                ),
              ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: Colors.transparent,
                  inactiveTrackColor: Colors.transparent,
                  thumbColor: AppColors.laranjaTerracota,
                  overlayColor: AppColors.laranjaTerracota.withValues(
                    alpha: 0.2,
                  ),
                ),
                child: Slider(
                  value: severityValue,
                  min: 0,
                  max: 2,
                  divisions: 2,
                  onChanged: onSeverityChanged,
                ),
              ),
            ],
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Baixo', style: TextStyle(fontSize: 12)),
              Text('Médio', style: TextStyle(fontSize: 12)),
              Text('Alto', style: TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Anotações adicionais',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Escreva aqui...',
              filled: true,
              fillColor: AppColors.cremeSuave,
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Pet',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: selectedPet,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.cremeSuave,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            items: [
              for (final pet in pets)
                DropdownMenuItem(value: pet, child: Text(pet)),
            ],
            onChanged: onPetChanged,
          ),
        ],
      ),
    );
  }
}

class _RecordsHistory extends StatelessWidget {
  const _RecordsHistory({required this.records});

  final List<_SymptomRecord> records;

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
      child: Column(
        children: [for (final record in records) _RecordTile(record: record)],
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.record});

  final _SymptomRecord record;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today,
            color: AppColors.laranjaTerracota,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${record.date}: ${record.symptom} - ${record.severity.label} (${record.pet})',
              style: const TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white,
            child: Icon(Icons.pets, size: 16, color: AppColors.laranjaSolar),
          ),
          const SizedBox(width: 6),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: record.severity.color,
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
    required this.onTapClinicas,
    required this.onTapLinhaDoTempo,
    required this.onTapPerfil,
  });

  final VoidCallback onTapInicio;
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
          case 0:
            onTapInicio();
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
