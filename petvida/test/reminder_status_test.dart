import 'package:flutter_test/flutter_test.dart';
import 'package:petvida/utils/reminder_status.dart';

void main() {
  final agora = DateTime(2026, 9, 18, 12, 0);

  group('calcularReminderStatus', () {
    test('retorna atrasado quando a próxima dose já passou', () {
      final proximaDose = agora.subtract(const Duration(days: 1));
      expect(
        calcularReminderStatus(proximaDose, agora: agora),
        ReminderStatus.atrasado,
      );
    });

    test(
      'retorna atrasado quando a próxima dose (medicamento em horas) já passou',
      () {
        final proximaDose = agora.subtract(const Duration(hours: 1));
        expect(
          calcularReminderStatus(proximaDose, agora: agora),
          ReminderStatus.atrasado,
        );
      },
    );

    test('retorna hoje quando falta menos de 24 horas', () {
      final proximaDose = agora.add(const Duration(hours: 5));
      expect(
        calcularReminderStatus(proximaDose, agora: agora),
        ReminderStatus.hoje,
      );
    });

    test('retorna proximo quando falta entre 1 e 3 dias', () {
      final proximaDose = agora.add(const Duration(days: 2));
      expect(
        calcularReminderStatus(proximaDose, agora: agora),
        ReminderStatus.proximo,
      );
    });

    test('retorna emDia quando falta bastante tempo', () {
      final proximaDose = agora.add(const Duration(days: 30));
      expect(
        calcularReminderStatus(proximaDose, agora: agora),
        ReminderStatus.emDia,
      );
    });
  });

  group('vacina: frequência entre doses avisa o tutor corretamente', () {
    test(
      'próxima dose calculada a partir da frequência em dias fica atrasada '
      'após o prazo passar',
      () {
        const frequenciaDias = 30;
        final dataAplicacao = agora.subtract(const Duration(days: 31));
        final proximaDose = dataAplicacao.add(
          const Duration(days: frequenciaDias),
        );

        expect(
          calcularReminderStatus(proximaDose, agora: agora),
          ReminderStatus.atrasado,
        );
      },
    );

    test(
      'após registrar a dose aplicada, a próxima dose deixa de estar atrasada',
      () {
        const frequenciaDias = 30;
        // Tutor acabou de registrar a dose "agora".
        final novaProximaDose = agora.add(
          const Duration(days: frequenciaDias),
        );

        expect(
          calcularReminderStatus(novaProximaDose, agora: agora),
          ReminderStatus.emDia,
        );
      },
    );
  });

  group(
    'medicamento: frequência entre doses avisa o tutor corretamente',
    () {
      test(
        'medicamento a cada 12h fica "hoje" poucas horas antes do prazo',
        () {
          const frequenciaHoras = 12;
          final ultimaDose = agora.subtract(const Duration(hours: 8));
          final proximaDose = ultimaDose.add(
            const Duration(hours: frequenciaHoras),
          );

          expect(
            calcularReminderStatus(proximaDose, agora: agora),
            ReminderStatus.hoje,
          );
        },
      );

      test(
        'medicamento a cada 12h fica atrasado quando o horário já passou',
        () {
          const frequenciaHoras = 12;
          final ultimaDose = agora.subtract(const Duration(hours: 13));
          final proximaDose = ultimaDose.add(
            const Duration(hours: frequenciaHoras),
          );

          expect(
            calcularReminderStatus(proximaDose, agora: agora),
            ReminderStatus.atrasado,
          );
        },
      );

      test(
        'registrar a dose administrada recalcula a próxima dose corretamente',
        () {
          const frequenciaHoras = 12;
          // Tutor acabou de registrar a dose "agora".
          final novaProximaDose = agora.add(
            const Duration(hours: frequenciaHoras),
          );

          expect(
            calcularReminderStatus(novaProximaDose, agora: agora),
            ReminderStatus.hoje,
          );
        },
      );
    },
  );
}
