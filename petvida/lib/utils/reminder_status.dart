import 'package:flutter/material.dart';

/// Status de um lembrete de vacina ou medicamento, usado para avisar
/// o tutor quando uma nova dose deve ser aplicada.
enum ReminderStatus { atrasado, hoje, proximo, emDia }

/// Calcula o status do lembrete comparando [proximaData] (quando a
/// próxima dose deve ser aplicada) com o momento atual.
///
/// - [ReminderStatus.atrasado]: já passou da data/hora da próxima dose.
/// - [ReminderStatus.hoje]: falta menos de 24 horas.
/// - [ReminderStatus.proximo]: falta menos que [limiteProximo] (padrão 3 dias).
/// - [ReminderStatus.emDia]: ainda falta bastante tempo.
ReminderStatus calcularReminderStatus(
  DateTime proximaData, {
  DateTime? agora,
  Duration limiteProximo = const Duration(days: 3),
}) {
  final now = agora ?? DateTime.now();
  final diferenca = proximaData.difference(now);
  if (diferenca.isNegative) return ReminderStatus.atrasado;
  if (diferenca <= const Duration(hours: 24)) return ReminderStatus.hoje;
  if (diferenca <= limiteProximo) return ReminderStatus.proximo;
  return ReminderStatus.emDia;
}

String reminderLabel(ReminderStatus status) {
  switch (status) {
    case ReminderStatus.atrasado:
      return 'Atrasada';
    case ReminderStatus.hoje:
      return 'Vence hoje';
    case ReminderStatus.proximo:
      return 'Vence em breve';
    case ReminderStatus.emDia:
      return 'Em dia';
  }
}

Color reminderColor(ReminderStatus status) {
  switch (status) {
    case ReminderStatus.atrasado:
      return Colors.red.shade600;
    case ReminderStatus.hoje:
      return Colors.orange.shade700;
    case ReminderStatus.proximo:
      return Colors.amber.shade700;
    case ReminderStatus.emDia:
      return Colors.green.shade600;
  }
}

String formatarDataHora(DateTime data) {
  final dia = data.day.toString().padLeft(2, '0');
  final mes = data.month.toString().padLeft(2, '0');
  final hora = data.hour.toString().padLeft(2, '0');
  final minuto = data.minute.toString().padLeft(2, '0');
  return '$dia/$mes/${data.year} $hora:$minuto';
}
