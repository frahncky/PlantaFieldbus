import 'dart:async';
import 'dart:math';

import '../domain/plant_models.dart';
import 'plant_adapter.dart';

class SimulationAdapter implements PlantAdapter {
  SimulationAdapter({this.interval = const Duration(seconds: 1)});

  final Duration interval;
  double _phase = 0;

  @override
  String get displayName => 'Simulador local';

  @override
  bool get isReadOnly => true;

  @override
  Future<void> disconnect() async {}

  @override
  Stream<PlantSnapshot> watch() {
    Timer? timer;
    late final StreamController<PlantSnapshot> controller;

    void emitSnapshot() {
      final now = DateTime.now();
      _phase += .22;
      final level = 68 + cos(_phase * .7) * 3.2;
      final temperature = 64 + sin(_phase * .45) * 1.8;
      const temperatureSetpoint = 65.0;
      // Offline model based on the DF51 factory cascade example:
      // Temperature-PID supplies the Flow-PID reference; Flow-PID drives valve.
      final flowSetpoint = 42 + (temperatureSetpoint - temperature) * 2.2;
      final flow = flowSetpoint + sin(_phase) * 1.4;
      final valvePosition = (flow / 60 * 100).clamp(0, 100).toDouble();
      final pressure = 2.42 + sin(_phase * 1.3) * .12;
      controller.add(
        PlantSnapshot(
          tags: {
            'temperature': PlantTag(
              id: 'temperature',
              label: 'Temperatura (TT302 simulado)',
              value: temperature,
              unit: '°C',
              observedAt: now,
            ),
            'temperature_sp': PlantTag(
              id: 'temperature_sp',
              label: 'Referência de temperatura (simulada)',
              value: temperatureSetpoint,
              unit: '°C',
              observedAt: now,
            ),
            'flow_sp': PlantTag(
              id: 'flow_sp',
              label: 'Referência de vazão do PID mestre (simulada)',
              value: flowSetpoint,
              unit: 'L/min',
              observedAt: now,
            ),
            'level': PlantTag(
              id: 'level',
              label: 'Nível do tanque',
              value: level,
              unit: '%',
              observedAt: now,
            ),
            'flow': PlantTag(
              id: 'flow',
              label: 'Vazão',
              value: flow,
              unit: 'L/min',
              observedAt: now,
            ),
            'pressure': PlantTag(
              id: 'pressure',
              label: 'Pressão',
              value: pressure,
              unit: 'bar',
              observedAt: now,
            ),
            'valve_position': PlantTag(
              id: 'valve_position',
              label: 'Posição da válvula (FP302 simulada)',
              value: valvePosition,
              unit: '%',
              observedAt: now,
            ),
          },
          events: [
            PlantEvent(
              time: now,
              message: 'Cascata DF51 de fábrica simulada e atualizada',
              severity: EventSeverity.info,
            ),
          ],
        ),
      );
    }

    controller = StreamController<PlantSnapshot>(
      onListen: () {
        emitSnapshot();
        timer = Timer.periodic(interval, (_) => emitSnapshot());
      },
      onCancel: () => timer?.cancel(),
    );
    return controller.stream;
  }
}
---TEST---
import 'package:flutter_test/flutter_test.dart';
import 'package:planta_fieldbus_app/adapters/simulation_adapter.dart';

void main() {
  test('simulation supplies read-only tagged snapshots', () async {
    final adapter = SimulationAdapter(interval: Duration.zero);
    final snapshot = await adapter.watch().first;

    expect(adapter.isReadOnly, isTrue);
    expect(snapshot.tags['level']!.unit, '%');
    expect(snapshot.tags['flow']!.value, greaterThan(0));
    expect(snapshot.tags['temperature']!.unit, '°C');
    expect(snapshot.tags['flow_sp']!.unit, 'L/min');
    expect(snapshot.tags['valve_position']!.value, inInclusiveRange(0, 100));
    expect(snapshot.events.single.message, contains('Cascata DF51'));
  });
}
---DOC---
# Exemplos de fábrica DF51 usados somente offline

Os arquivos instalados com o System302 foram inspecionados estaticamente e são
usados como referência para documentação, simulação e testes offline. Eles não
devem ser importados, comparados online, baixados ou usados para alterar a
PD3-302.

| Exemplo | SHA-256 | Topologia adicional |
| --- | --- | --- |
| \`DF51_SE.ffp\` | \`7384beb88959422ed8b025451c6cb85e4bc61b12eea171583e6b83c4657431e4\` | Uma rede \`Fieldbus1\` e bridge \`DFI302\` |
| \`DF51_HSE.ffp\` | \`90265d0327f0ee79db6bd8f9564e9d935329beaee27be825f9f69e73dd948f8d\` | \`Fieldbus1\`, \`HSE Network\`, host \`HSE_HOST\` e bridge \`DFI302\` |

## Estratégia de controle comum

Os dois projetos trazem uma estratégia chamada \`Cascade\`:

\`\`\`text
TT302 / Temperature-AI → Temperature-PID
                              ↓ CAS_IN
LD302 / Flow-AI        → Flow-PID → Flow Valve-AO / FP302
\`\`\`

O PID de temperatura fornece a referência para o PID de vazão; o PID de vazão
atua sobre a válvula. Há também *Resource Blocks*, blocos transdutores,
agendas de execução e agenda de tráfego FOUNDATION Fieldbus.

## Uso permitido neste repositório

1. Comparar nomes de blocos, ligações e tipos de equipamentos com evidência
   posterior da bancada.
2. Derivar dados de demonstração para o aplicativo, marcados como simulados.
3. Construir testes de replay e documentação do processo de cascata.

## Uso proibido até recuperação validada

- Abrir os exemplos conectados ao DF51.
- Fazer *download*, *upload*, comparação online, firmware, RUN/HOLD ou escrita
  de parâmetros.
- Assumir que TT302, LD302, FP302, tags ou escalas existem na PD3-302 real.

Os exemplos são material didático de referência; não são backup, cópia ou
modelo confirmado da planta instalada.
