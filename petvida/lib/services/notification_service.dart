import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Lembretes locais reais (RF05/RNF06): avisa o tutor com a antecedência
/// necessária para a próxima dose de vacina/medicamento, mesmo com o app
/// fechado, usando notificações agendadas pelo próprio sistema operacional.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    // Não dependemos do nome IANA do fuso do aparelho: convertemos cada
    // horário-alvo para UTC antes de agendar, preservando o instante real
    // correspondente ao horário local calculado.
    tz.setLocalLocation(tz.UTC);

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      settings: const InitializationSettings(android: androidInit),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  int _idVacina(String petId, String vacinaId) =>
      'vacina-$petId-$vacinaId'.hashCode & 0x7fffffff;

  int _idMedicamento(String petId, String medicamentoId) =>
      'medicamento-$petId-$medicamentoId'.hashCode & 0x7fffffff;

  tz.TZDateTime _paraTz(DateTime data) => tz.TZDateTime.from(data.toUtc(), tz.UTC);

  /// Garante um horário estritamente futuro (o plugin rejeita datas
  /// passadas): se o cálculo já ficou pra trás, dispara em alguns segundos
  /// em vez de simplesmente não notificar o tutor.
  DateTime _garantirFuturo(DateTime data) {
    final agora = DateTime.now();
    return data.isAfter(agora) ? data : agora.add(const Duration(seconds: 10));
  }

  /// Agenda (ou reagenda, cancelando o anterior) o aviso de uma vacina para
  /// 7 dias antes da próxima dose prevista, conforme RF05.
  Future<void> agendarLembreteVacina({
    required String petId,
    required String vacinaId,
    required String nomePet,
    required String nomeVacina,
    required DateTime proximaDose,
  }) async {
    await initialize();
    final id = _idVacina(petId, vacinaId);
    await _plugin.cancel(id: id);

    final disparo = _garantirFuturo(
      proximaDose.subtract(const Duration(days: 7)),
    );

    await _plugin.zonedSchedule(
      id: id,
      title: 'Vacina de $nomePet',
      body:
          'A vacina "$nomeVacina" de $nomePet está prevista para '
          '${_formatarData(proximaDose)}. Não esqueça de agendar a aplicação!',
      scheduledDate: _paraTz(disparo),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'vacinas_lembretes',
          'Lembretes de Vacina',
          channelDescription:
              'Avisos com 7 dias de antecedência para a próxima dose de vacina.',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelarLembreteVacina(String petId, String vacinaId) async {
    await initialize();
    await _plugin.cancel(id: _idVacina(petId, vacinaId));
  }

  /// Agenda (ou reagenda) o aviso de um medicamento para o horário exato da
  /// próxima dose (frequência em horas, diferente da antecedência de dias
  /// usada para vacinas).
  Future<void> agendarLembreteMedicamento({
    required String petId,
    required String medicamentoId,
    required String nomePet,
    required String nomeMedicamento,
    required DateTime proximaDose,
  }) async {
    await initialize();
    final id = _idMedicamento(petId, medicamentoId);
    await _plugin.cancel(id: id);

    final disparo = _garantirFuturo(proximaDose);

    await _plugin.zonedSchedule(
      id: id,
      title: 'Medicamento de $nomePet',
      body:
          'Hora de dar "$nomeMedicamento" para $nomePet '
          '(previsto para ${_formatarDataHora(proximaDose)}).',
      scheduledDate: _paraTz(disparo),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'medicamentos_lembretes',
          'Lembretes de Medicamento',
          channelDescription: 'Avisos na hora de administrar cada dose.',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelarLembreteMedicamento(
    String petId,
    String medicamentoId,
  ) async {
    await initialize();
    await _plugin.cancel(id: _idMedicamento(petId, medicamentoId));
  }

  /// Cancela todos os lembretes agendados no aparelho — usado ao excluir a
  /// conta do tutor (LGPD/RF12), pra não deixar notificações órfãs.
  Future<void> cancelarTudo() async {
    await initialize();
    await _plugin.cancelAll();
  }
}

String _formatarData(DateTime data) {
  final dia = data.day.toString().padLeft(2, '0');
  final mes = data.month.toString().padLeft(2, '0');
  return '$dia/$mes/${data.year}';
}

String _formatarDataHora(DateTime data) {
  final hora = data.hour.toString().padLeft(2, '0');
  final minuto = data.minute.toString().padLeft(2, '0');
  return '${_formatarData(data)} $hora:$minuto';
}
