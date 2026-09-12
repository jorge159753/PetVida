import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../theme/app_colors.dart';
import '../widgets/paw_prints_background.dart';
import '../widgets/petvida_logo.dart';
import 'clinics_screen.dart';
import 'historico_medico_screen.dart';
import 'medicamentos_screen.dart';
import 'perfil_screen.dart';
import 'timeline_screen.dart';

/// Tela de perfil do pet (ver imagens/perfil pet.png).
///
/// Quando [petId] é informado e o Firebase está inicializado, o botão
/// "Adicionar Vacina" salva em users/{uid}/pets/{petId}/vacinas no
/// Firestore e a lista de vacinas é exibida em tempo real.
class PetProfileScreen extends StatelessWidget {
  const PetProfileScreen({
    super.key,
    this.petId,
    this.nome = 'Fofo',
    this.especie = 'Gato',
    this.idade = '2 anos',
    this.badges = const ['Vacina OK', 'Peso Ideal', 'Check-up em Dia'],
  });

  final String? petId;
  final String nome;
  final String especie;
  final String idade;
  final List<String> badges;

  DocumentReference<Map<String, dynamic>>? get _petDocument {
    if (petId == null || Firebase.apps.isEmpty) return null;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('pets')
        .doc(petId);
  }

  CollectionReference<Map<String, dynamic>>? get _vacinasCollection {
    return _petDocument?.collection('vacinas');
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleAdicionarVacina(BuildContext context) async {
    final collection = _vacinasCollection;
    if (collection == null) {
      _showSnackBar(context, 'Não é possível adicionar vacina para este pet.');
      return;
    }

    final dados = await showDialog<Map<String, Object>>(
      context: context,
      builder: (_) => const _AddVaccineDialog(),
    );
    if (dados == null) return;

    try {
      await collection.add({
        'nome': dados['nome'],
        'dataAplicacao': dados['dataAplicacao'],
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (context.mounted) {
        _showSnackBar(context, 'Vacina adicionada com sucesso!');
      }
    } catch (_) {
      if (context.mounted) {
        _showSnackBar(context, 'Não foi possível adicionar a vacina.');
      }
    }
  }

  Future<void> _handleEditarFoto(BuildContext context) async {
    final doc = _petDocument;
    if (doc == null) {
      _showSnackBar(context, 'Não é possível editar a foto deste pet.');
      return;
    }

    final fotoBase64 = await _escolherNovaFotoBase64(context);
    if (fotoBase64 == null) return;

    try {
      await doc.update({'fotoBase64': fotoBase64});
      if (context.mounted) {
        _showSnackBar(context, 'Foto atualizada com sucesso!');
      }
    } catch (_) {
      if (context.mounted) {
        _showSnackBar(context, 'Não foi possível atualizar a foto.');
      }
    }
  }

  Future<void> _handleEditar(
    BuildContext context,
    Map<String, dynamic>? dadosAtuais,
  ) async {
    final doc = _petDocument;
    if (doc == null) {
      _showSnackBar(context, 'Não é possível editar este pet.');
      return;
    }

    final resultado = await showDialog<Map<String, String?>>(
      context: context,
      builder: (_) => _EditPetDialog(
        nomeInicial: (dadosAtuais?['nome'] as String?) ?? nome,
        especieInicial: (dadosAtuais?['especie'] as String?) ?? especie,
        idadeInicial: (dadosAtuais?['idade'] as String?) ?? idade,
        fotoBase64Inicial: dadosAtuais?['fotoBase64'] as String?,
      ),
    );
    if (resultado == null) return;

    try {
      await doc.update(resultado);
      if (context.mounted) {
        _showSnackBar(context, 'Pet atualizado com sucesso!');
      }
    } catch (_) {
      if (context.mounted) {
        _showSnackBar(context, 'Não foi possível atualizar o pet.');
      }
    }
  }

  Future<void> _handleExcluir(BuildContext context) async {
    final doc = _petDocument;
    if (doc == null) {
      _showSnackBar(context, 'Não é possível excluir este pet.');
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cremeSuave,
        title: const Text(
          'Excluir Pet',
          style: TextStyle(
            color: AppColors.laranjaTerracota,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Tem certeza que deseja excluir $nome? Essa ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    try {
      final vacinas = await doc.collection('vacinas').get();
      for (final vacinaDoc in vacinas.docs) {
        await vacinaDoc.reference.delete();
      }
      await doc.delete();
      if (context.mounted) Navigator.of(context).pop();
    } catch (_) {
      if (context.mounted) {
        _showSnackBar(context, 'Não foi possível excluir o pet.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final petDocument = _petDocument;
    final vacinasCollection = _vacinasCollection;
    return Scaffold(
      backgroundColor: AppColors.cremeSuave,
      body: PawPrintsBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (petDocument == null)
                  _PetHeader(
                    nome: nome,
                    especie: especie,
                    idade: idade,
                    badges: badges,
                    fotoBase64: null,
                    onEditar: null,
                    onTapFoto: null,
                  )
                else
                  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: petDocument.snapshots(),
                    builder: (context, snapshot) {
                      final dados = snapshot.data?.data();
                      return _PetHeader(
                        nome: (dados?['nome'] as String?) ?? nome,
                        especie: (dados?['especie'] as String?) ?? especie,
                        idade: (dados?['idade'] as String?) ?? idade,
                        badges: badges,
                        fotoBase64: dados?['fotoBase64'] as String?,
                        onEditar: () => _handleEditar(context, dados),
                        onTapFoto: () => _handleEditarFoto(context),
                      );
                    },
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                  child: Column(
                    children: [
                      _AddVaccineButton(
                        onTap: () => _handleAdicionarVacina(context),
                      ),
                      if (vacinasCollection != null) ...[
                        const SizedBox(height: 20),
                        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: vacinasCollection
                              .orderBy('dataAplicacao', descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            final docs = snapshot.data?.docs ?? [];
                            return _VaccinesSection(docs: docs);
                          },
                        ),
                      ],
                      const SizedBox(height: 20),
                      _PetListItem(
                        icon: Icons.local_hospital,
                        label: 'Histórico Médico',
                        onTap: () {
                          final id = petId;
                          if (id == null) {
                            _showSnackBar(
                              context,
                              'Não é possível abrir o histórico deste pet.',
                            );
                            return;
                          }
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => HistoricoMedicoScreen(
                                petId: id,
                                nomePet: nome,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _PetListItem(
                        icon: Icons.medication,
                        label: 'Medicamentos Atuais',
                        onTap: () {
                          final id = petId;
                          if (id == null) {
                            _showSnackBar(
                              context,
                              'Não é possível abrir os medicamentos deste pet.',
                            );
                            return;
                          }
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  MedicamentosScreen(petId: id, nomePet: nome),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _PetListItem(
                        icon: Icons.settings,
                        label: 'Configurações do Pet',
                        onTap: () => _handleEditar(context, null),
                      ),
                      if (petDocument != null) ...[
                        const SizedBox(height: 20),
                        _DeletePetButton(onTap: () => _handleExcluir(context)),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _PetProfileBottomNav(
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

/// Abre um seletor de origem (galeria/câmera), escolhe a imagem e retorna
/// seu conteúdo como Base64 já redimensionado, ou `null` se o usuário
/// cancelar ou a seleção falhar.
Future<String?> _escolherNovaFotoBase64(BuildContext context) async {
  final origem = await showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: AppColors.cremeSuave,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(
              Icons.photo_library,
              color: AppColors.laranjaTerracota,
            ),
            title: const Text('Escolher da galeria'),
            onTap: () => Navigator.of(context).pop(ImageSource.gallery),
          ),
          ListTile(
            leading: const Icon(
              Icons.photo_camera,
              color: AppColors.laranjaTerracota,
            ),
            title: const Text('Tirar foto'),
            onTap: () => Navigator.of(context).pop(ImageSource.camera),
          ),
        ],
      ),
    ),
  );
  if (origem == null) return null;

  try {
    final arquivo = await ImagePicker().pickImage(
      source: origem,
      maxWidth: 400,
      maxHeight: 400,
      imageQuality: 70,
    );
    if (arquivo == null) return null;
    final bytes = await arquivo.readAsBytes();
    return base64Encode(bytes);
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível selecionar a foto.')),
      );
    }
    return null;
  }
}

String _formatarData(DateTime data) {
  final dia = data.day.toString().padLeft(2, '0');
  final mes = data.month.toString().padLeft(2, '0');
  return '$dia/$mes/${data.year}';
}

class _VaccinesSection extends StatelessWidget {
  const _VaccinesSection({required this.docs});

  final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vacinas Registradas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.laranjaTerracota,
          ),
        ),
        const SizedBox(height: 12),
        if (docs.isEmpty)
          const Text(
            'Nenhuma vacina registrada ainda.',
            style: TextStyle(color: Colors.black54),
          )
        else
          for (final doc in docs) ...[
            _VaccineTile(data: doc.data()),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _VaccineTile extends StatelessWidget {
  const _VaccineTile({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final nome = (data['nome'] as String?) ?? 'Vacina';
    final timestamp = data['dataAplicacao'] as Timestamp?;
    final dataTexto = timestamp == null
        ? 'Data não informada'
        : _formatarData(timestamp.toDate());
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.vaccines, color: AppColors.laranjaTerracota),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  'Aplicada em $dataTexto',
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
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
    required this.fotoBase64,
    required this.onEditar,
    required this.onTapFoto,
  });

  final String nome;
  final String especie;
  final String idade;
  final List<String> badges;
  final String? fotoBase64;
  final VoidCallback? onEditar;
  final VoidCallback? onTapFoto;

  ImageProvider? get _fotoProvider {
    final base64 = fotoBase64;
    if (base64 == null || base64.isEmpty) return null;
    try {
      return MemoryImage(base64Decode(base64));
    } catch (_) {
      return null;
    }
  }

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
            children: [
              SizedBox(width: onEditar != null ? 84 : 40, height: 40),
              const Expanded(child: Center(child: PetVidaLogo(size: 64))),
              Row(
                children: [
                  if (onEditar != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: onEditar,
                        child: const CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.edit,
                            size: 18,
                            color: AppColors.laranjaTerracota,
                          ),
                        ),
                      ),
                    ),
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: AppColors.laranjaSolar),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: onTapFoto,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundColor: AppColors.begePata,
                      backgroundImage: _fotoProvider,
                      child: _fotoProvider == null
                          ? const Icon(
                              Icons.pets,
                              size: 60,
                              color: AppColors.laranjaTerracota,
                            )
                          : null,
                    ),
                    if (onTapFoto != null)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.laranjaTerracota,
                          child: const Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
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

class _AddVaccineDialog extends StatefulWidget {
  const _AddVaccineDialog();

  @override
  State<_AddVaccineDialog> createState() => _AddVaccineDialogState();
}

class _AddVaccineDialogState extends State<_AddVaccineDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  DateTime _dataAplicacao = DateTime.now();

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _escolherData() async {
    final selecionada = await showDatePicker(
      context: context,
      initialDate: _dataAplicacao,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (selecionada != null) {
      setState(() => _dataAplicacao = selecionada);
    }
  }

  void _handleSalvar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop({
      'nome': _nomeController.text.trim(),
      'dataAplicacao': Timestamp.fromDate(_dataAplicacao),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cremeSuave,
      title: const Text(
        'Adicionar Vacina',
        style: TextStyle(
          color: AppColors.laranjaTerracota,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome da vacina (ex: V10)',
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Digite o nome da vacina'
                  : null,
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Data de aplicação'),
              subtitle: Text(_formatarData(_dataAplicacao)),
              trailing: const Icon(
                Icons.calendar_today,
                color: AppColors.laranjaTerracota,
              ),
              onTap: _escolherData,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _handleSalvar,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.laranjaTerracota,
            foregroundColor: Colors.white,
          ),
          child: const Text('Salvar'),
        ),
      ],
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
  const _PetProfileBottomNav({
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

class _DeletePetButton extends StatelessWidget {
  const _DeletePetButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        icon: const Icon(Icons.delete_outline),
        label: const Text(
          'Excluir Pet',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _EditPetDialog extends StatefulWidget {
  const _EditPetDialog({
    required this.nomeInicial,
    required this.especieInicial,
    required this.idadeInicial,
    required this.fotoBase64Inicial,
  });

  final String nomeInicial;
  final String especieInicial;
  final String idadeInicial;
  final String? fotoBase64Inicial;

  @override
  State<_EditPetDialog> createState() => _EditPetDialogState();
}

class _EditPetDialogState extends State<_EditPetDialog> {
  final _formKey = GlobalKey<FormState>();
  late final _nomeController = TextEditingController(text: widget.nomeInicial);
  late final _especieController = TextEditingController(
    text: widget.especieInicial,
  );
  late final _idadeController = TextEditingController(
    text: widget.idadeInicial,
  );
  String? _fotoBase64;
  bool _fotoAlterada = false;

  @override
  void initState() {
    super.initState();
    _fotoBase64 = widget.fotoBase64Inicial;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _especieController.dispose();
    _idadeController.dispose();
    super.dispose();
  }

  Future<void> _escolherFoto() async {
    final fotoBase64 = await _escolherNovaFotoBase64(context);
    if (fotoBase64 == null) return;
    setState(() {
      _fotoBase64 = fotoBase64;
      _fotoAlterada = true;
    });
  }

  void _handleSalvar() {
    if (!_formKey.currentState!.validate()) return;
    final resultado = <String, String?>{
      'nome': _nomeController.text.trim(),
      'especie': _especieController.text.trim(),
      'idade': _idadeController.text.trim(),
    };
    if (_fotoAlterada) {
      resultado['fotoBase64'] = _fotoBase64;
    }
    Navigator.of(context).pop(resultado);
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? fotoProvider;
    final base64 = _fotoBase64;
    if (base64 != null && base64.isNotEmpty) {
      try {
        fotoProvider = MemoryImage(base64Decode(base64));
      } catch (_) {
        fotoProvider = null;
      }
    }

    return AlertDialog(
      backgroundColor: AppColors.cremeSuave,
      title: const Text(
        'Editar Pet',
        style: TextStyle(
          color: AppColors.laranjaTerracota,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _escolherFoto,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.begePata,
                      backgroundImage: fotoProvider,
                      child: fotoProvider == null
                          ? const Icon(
                              Icons.pets,
                              size: 36,
                              color: AppColors.laranjaTerracota,
                            )
                          : null,
                    ),
                    const Positioned(
                      right: 0,
                      bottom: 0,
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.laranjaTerracota,
                        child: Icon(
                          Icons.camera_alt,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Digite o nome do pet'
                    : null,
              ),
              TextFormField(
                controller: _especieController,
                decoration: const InputDecoration(
                  labelText: 'Espécie (ex: Cão, Gato)',
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Digite a espécie'
                    : null,
              ),
              TextFormField(
                controller: _idadeController,
                decoration: const InputDecoration(
                  labelText: 'Idade (ex: 2 anos)',
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _handleSalvar,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.laranjaTerracota,
            foregroundColor: Colors.white,
          ),
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
