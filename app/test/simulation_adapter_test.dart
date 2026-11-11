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
