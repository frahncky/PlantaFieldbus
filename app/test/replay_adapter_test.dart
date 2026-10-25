import 'package:flutter_test/flutter_test.dart';
import 'package:planta_fieldbus_app/adapters/replay_adapter.dart';
import 'package:planta_fieldbus_app/domain/plant_models.dart';

void main() {
  test('replays frames in preserved order without write capability', () async {
    final now = DateTime.utc(2026, 10, 25);
    final adapter = ReplayAdapter([
      PlantSnapshot(
        tags: {
          'level': PlantTag(
            id: 'level',
            label: 'Nível',
            value: 10,
            unit: '%',
            observedAt: now,
          ),
        },
        events: const [],
      ),
      PlantSnapshot(
        tags: {
          'level': PlantTag(
            id: 'level',
            label: 'Nível',
            value: 20,
            unit: '%',
            observedAt: now,
          ),
        },
        events: const [],
      ),
    ], interval: Duration.zero);

    final frames = await adapter.watch().toList();

    expect(adapter.isReadOnly, isTrue);
    expect(frames.map((frame) => frame.tags['level']!.value), [10, 20]);
  });
}
