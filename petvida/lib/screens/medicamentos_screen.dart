import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../services/notification_service.dart';
import '../theme/app_colors.dart';
import '../utils/reminder_status.dart';
import '../widgets/paw_prints_background.dart';
import '../widgets/petvida_logo.dart';
import '../widgets/reminder_badge.dart';

/// Medicamentos atuais de um pet (users/{uid}/pets/{petId}/medicamentos).
class MedicamentosScreen extends StatelessWidget {
  const MedicamentosScreen({
    super.key,
    required this.petId,
    required this.nomePet,
  });

  final String petId;
  final String nomePet;

  CollectionReference<Map<String, dynamic>>? get _collection {
    if (Firebase.apps.isEmpty) return null;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('pets')
        .doc(petId)
        .collection('medicamentos');
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleAdicionar(BuildContext context) async {
    final collection = _collection;
    if (collection == null) {
      _showSnackBar(context, 'Não é possível adicionar um medicamento agora.');
      return;
    }

    final dados = await showDialog<Map<String, Object>>(
      context: context,
      builder: (_) => const _MedicamentoDialog(),
    );
    if (dados == null) return;

    try {
      final frequenciaHoras = dados['frequenciaHoras'] as int;
      final numeroDoses = dados['numeroDoses'] as int;
      final agora = DateTime.now();
      final proximaDose = numeroDoses > 1
          ? Timestamp.fromDate(agora.add(Duration(hours: frequenciaHoras)))
          : null;
      final doc = await collection.add({
        'nome': dados['nome'],
        'dosagem': dados['dosagem'],
        'frequenciaHoras': frequenciaHoras,
        'numeroDoses': numeroDoses,
        'doseAtual': 1,
        'ultimaDose': Timestamp.fromDate(agora),
        'proximaDose': proximaDose,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await doc.collection('doses').add({
        'numero': 1,
        'dataAplicacao': Timestamp.fromDate(agora),
      });
      if (proximaDose != null) {
        try {
          await NotificationService.instance.agendarLembreteMedicamento(
            petId: petId,
            medicamentoId: doc.id,
            nomePet: nomePet,
            nomeMedicamento: dados['nome'] as String,
            proximaDose: proximaDose.toDate(),
          );
        } catch (_) {
          // O medicamento já foi salvo; falha ao agendar o lembrete local
          // não deve impedir o fluxo principal.
        }
      }
      if (context.mounted) {
        _showSnackBar(context, 'Medicamento adicionado com sucesso!');
      }
    } catch (_) {
      if (context.mounted) {
        _showSnackBar(context, 'Não foi possível adicionar o medicamento.');
      }
    }
  }

  Future<void> _handleRegistrarDose(
    BuildContext context,
    DocumentReference<Map<String, dynamic>> doc,
    Map<String, dynamic> data,
  ) async {
    final numeroDoses = (data['numeroDoses'] as num?)?.toInt() ?? 1;
    final frequenciaHoras = (data['frequenciaHoras'] as num?)?.toInt() ?? 0;
    final doseAtual = (data['doseAtual'] as num?)?.toInt() ?? 1;
    final novaDose = doseAtual + 1;
    final agora = DateTime.now();
    final proximaDose = novaDose < numeroDoses
        ? Timestamp.fromDate(agora.add(Duration(hours: frequenciaHoras)))
        : null;
    try {
      await doc.update({
        'doseAtual': novaDose,
        'ultimaDose': Timestamp.fromDate(agora),
        'proximaDose': proximaDose,
      });
      await doc.collection('doses').add({
        'numero': novaDose,
        'dataAplicacao': Timestamp.fromDate(agora),
      });
      try {
        if (proximaDose != null) {
          await NotificationService.instance.agendarLembreteMedicamento(
            petId: petId,
            medicamentoId: doc.id,
            nomePet: nomePet,
            nomeMedicamento: (data['nome'] as String?) ?? 'Medicamento',
            proximaDose: proximaDose.toDate(),
          );
        } else {
          await NotificationService.instance.cancelarLembreteMedicamento(
            petId,
            doc.id,
          );
        }
      } catch (_) {
        // Não afeta o registro da dose, que já foi salvo com sucesso.
      }
      if (context.mounted) {
        _showSnackBar(context, 'Dose registrada com sucesso!');
      }
    } catch (_) {
      if (context.mounted) {
        _showSnackBar(context, 'Não foi possível registrar a dose.');
      }
    }
  }

  void _handleVerDoses(
    BuildContext context,
    DocumentReference<Map<String, dynamic>> doc,
    Map<String, dynamic> data,
  ) {
    final nome = (data['nome'] as String?) ?? 'Medicamento';
    final numeroDoses = (data['numeroDoses'] as num?)?.toInt() ?? 1;
    final frequenciaHoras = (data['frequenciaHoras'] as num?)?.toInt() ?? 0;
    final doseAtual = (data['doseAtual'] as num?)?.toInt() ?? 1;
    final ultimaDoseTimestamp = data['ultimaDose'] as Timestamp?;

    showDialog<void>(
      context: context,
      builder: (_) => _DosesDialog(
        nome: nome,
        numeroDoses: numeroDoses,
        frequenciaHoras: frequenciaHoras,
        doseAtual: doseAtual,
        ultimaDose: ultimaDoseTimestamp?.toDate() ?? DateTime.now(),
        dosesCollection: doc.collection('doses'),
      ),
    );
  }

  Future<void> _handleExcluir(
    BuildContext context,
    DocumentReference<Map<String, dynamic>> doc,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cremeSuave,
        title: const Text('Remover Medicamento'),
        content: const Text('Tem certeza que deseja remover este medicamento?'),
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
            child: const Text('Remover'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    try {
      await doc.delete();
      try {
        await NotificationService.instance.cancelarLembreteMedicamento(
          petId,
          doc.id,
        );
      } catch (_) {
        // A remoção do medicamento não deve falhar por causa do lembrete.
      }
    } catch (_) {
      if (context.mounted) {
        _showSnackBar(context, 'Não foi possível remover o medicamento.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final collection = _collection;
    return Scaffold(
      backgroundColor: AppColors.cremeSuave,
      body: PawPrintsBackground(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                width: double.infinity,
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
                          onTap: () => Navigator.of(context).maybePop(),
                          child: const CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.laranjaTerracota,
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Center(child: PetVidaLogo(size: 64)),
                        ),
                        const SizedBox(width: 36),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Medicamentos de $nomePet',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.laranjaTerracota,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: collection == null
                    ? const Center(
                        child: Text(
                          'Não foi possível carregar os medicamentos.',
                        ),
                      )
                    : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: collection
                            .orderBy('createdAt', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          final docs = snapshot.data?.docs ?? [];
                          return ListView(
                            padding: const EdgeInsets.all(20),
                            children: [
                              if (docs.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 32),
                                  child: Center(
                                    child: Text(
                                      'Nenhum medicamento cadastrado.',
                                      style: TextStyle(color: Colors.black54),
                                    ),
                                  ),
                                )
                              else
                                for (final doc in docs) ...[
                                  _MedicamentoTile(
                                    data: doc.data(),
                                    onExcluir: () =>
                                        _handleExcluir(context, doc.reference),
                                    onRegistrarDose: () =>
                                        _handleRegistrarDose(
                                          context,
                                          doc.reference,
                                          doc.data(),
                                        ),
                                    onVerDoses: () => _handleVerDoses(
                                      context,
                                      doc.reference,
                                      doc.data(),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton.icon(
                                  onPressed: () => _handleAdicionar(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.laranjaTerracota,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  icon: const Icon(Icons.add),
                                  label: const Text(
                                    'Adicionar Medicamento',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MedicamentoTile extends StatelessWidget {
  const _MedicamentoTile({
    required this.data,
    required this.onExcluir,
    required this.onRegistrarDose,
    required this.onVerDoses,
  });

  final Map<String, dynamic> data;
  final VoidCallback onExcluir;
  final VoidCallback onRegistrarDose;
  final VoidCallback onVerDoses;

  @override
  Widget build(BuildContext context) {
    final nome = (data['nome'] as String?) ?? 'Medicamento';
    final dosagem = (data['dosagem'] as String?) ?? '';
    final frequenciaHoras = (data['frequenciaHoras'] as num?)?.toInt();
    final numeroDoses = (data['numeroDoses'] as num?)?.toInt();
    final doseAtual = (data['doseAtual'] as num?)?.toInt() ?? 1;
    final proximaDoseTimestamp = data['proximaDose'] as Timestamp?;
    final protocoloCompleto =
        numeroDoses != null && proximaDoseTimestamp == null;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.medication, color: AppColors.laranjaTerracota),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nome,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (dosagem.isNotEmpty)
                      Text(
                        'Dosagem: $dosagem',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    if (frequenciaHoras != null)
                      Text(
                        'Frequência: a cada $frequenciaHoras h',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    if (numeroDoses != null)
                      Text(
                        'Dose $doseAtual de $numeroDoses',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onExcluir,
                icon: const Icon(Icons.delete_outline, color: Colors.red),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (protocoloCompleto)
            const ReminderBadge(
              text: 'Protocolo completo',
              color: Colors.green,
            )
          else if (proximaDoseTimestamp != null)
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Próxima dose: ${formatarDataHora(proximaDoseTimestamp.toDate())}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                ReminderBadge(
                  text: reminderLabel(
                    calcularReminderStatus(proximaDoseTimestamp.toDate()),
                  ),
                  color: reminderColor(
                    calcularReminderStatus(proximaDoseTimestamp.toDate()),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onVerDoses,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.laranjaTerracota,
                    side: const BorderSide(color: AppColors.laranjaTerracota),
                  ),
                  child: const Text('Ver doses'),
                ),
              ),
              if (!protocoloCompleto && proximaDoseTimestamp != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onRegistrarDose,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.laranjaTerracota,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Registrar dose'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _MedicamentoDialog extends StatefulWidget {
  const _MedicamentoDialog();

  @override
  State<_MedicamentoDialog> createState() => _MedicamentoDialogState();
}

class _MedicamentoDialogState extends State<_MedicamentoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _dosagemController = TextEditingController();
  final _frequenciaController = TextEditingController(text: '12');
  final _numeroDosesController = TextEditingController(text: '1');

  @override
  void dispose() {
    _nomeController.dispose();
    _dosagemController.dispose();
    _frequenciaController.dispose();
    _numeroDosesController.dispose();
    super.dispose();
  }

  void _handleSalvar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop({
      'nome': _nomeController.text.trim(),
      'dosagem': _dosagemController.text.trim(),
      'frequenciaHoras': int.parse(_frequenciaController.text.trim()),
      'numeroDoses': int.parse(_numeroDosesController.text.trim()),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cremeSuave,
      title: const Text(
        'Adicionar Medicamento',
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
                labelText: 'Nome do medicamento',
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Digite o nome do medicamento'
                  : null,
            ),
            TextFormField(
              controller: _dosagemController,
              decoration: const InputDecoration(
                labelText: 'Dosagem (ex: 1 comprimido)',
              ),
            ),
            TextFormField(
              controller: _frequenciaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Frequência entre doses (horas)',
              ),
              validator: (value) {
                final numero = int.tryParse((value ?? '').trim());
                if (numero == null || numero < 1) {
                  return 'Digite uma frequência válida em horas';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _numeroDosesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantidade de doses',
              ),
              validator: (value) {
                final numero = int.tryParse((value ?? '').trim());
                if (numero == null || numero < 1) {
                  return 'Digite uma quantidade de doses válida';
                }
                return null;
              },
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

/// Mostra todas as doses de um medicamento (1..numeroDoses), indicando
/// quais já foram dadas (com data/hora real registrada) e quais ainda
/// faltam (com a data prevista, calculada a partir da frequência).
class _DosesDialog extends StatelessWidget {
  const _DosesDialog({
    required this.nome,
    required this.numeroDoses,
    required this.frequenciaHoras,
    required this.doseAtual,
    required this.ultimaDose,
    required this.dosesCollection,
  });

  final String nome;
  final int numeroDoses;
  final int frequenciaHoras;
  final int doseAtual;
  final DateTime ultimaDose;
  final CollectionReference<Map<String, dynamic>> dosesCollection;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.cremeSuave,
      title: Text(
        'Doses de $nome',
        style: const TextStyle(
          color: AppColors.laranjaTerracota,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: dosesCollection.orderBy('numero').snapshots(),
          builder: (context, snapshot) {
            final dadas = <int, DateTime>{
              for (final doc in snapshot.data?.docs ?? [])
                (doc.data()['numero'] as num).toInt():
                    (doc.data()['dataAplicacao'] as Timestamp).toDate(),
            };

            return ListView.separated(
              shrinkWrap: true,
              itemCount: numeroDoses,
              separatorBuilder: (_, _) => const Divider(height: 20),
              itemBuilder: (context, index) {
                final numero = index + 1;
                final dataDada = dadas[numero];

                if (dataDada != null) {
                  return _DoseRow(
                    numero: numero,
                    total: numeroDoses,
                    texto: 'Dada em ${formatarDataHora(dataDada)}',
                    dada: true,
                  );
                }

                final prevista = ultimaDose.add(
                  Duration(hours: frequenciaHoras * (numero - doseAtual)),
                );
                return _DoseRow(
                  numero: numero,
                  total: numeroDoses,
                  texto: 'Prevista para ${formatarDataHora(prevista)}',
                  dada: false,
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fechar'),
        ),
      ],
    );
  }
}

class _DoseRow extends StatelessWidget {
  const _DoseRow({
    required this.numero,
    required this.total,
    required this.texto,
    required this.dada,
  });

  final int numero;
  final int total;
  final String texto;
  final bool dada;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          dada ? Icons.check_circle : Icons.schedule,
          color: dada ? Colors.green.shade600 : Colors.black38,
          size: 22,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dose $numero de $total',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                texto,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
