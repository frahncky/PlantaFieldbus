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
      final flow = 42 + sin(_phase) * 2.8;
      final pressure = 2.42 + sin(_phase * 1.3) * .12;
      controller.add(
        PlantSnapshot(
          tags: {
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
          },
          events: [
            PlantEvent(
              time: now,
              message: 'Leitura simulada atualizada',
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
