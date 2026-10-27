import 'package:flutter_test/flutter_test.dart';
import 'package:planta_fieldbus_app/adapters/offline_plant_import.dart';

void main() {
  const parser = OfflinePlantImport();
  const valid = '{"schemaVersion":1,"frames":[{"observedAt":"2026-10-26T12:00:00Z",'
      '"tags":[{"id":"LI-101","label":"Nivel","value":42.0,"unit":"%"}]}]}';

  test('imports a read-only replay without network calls', () async {
    final replay = parser.parseReplay(valid);
    expect(replay.isReadOnly, isTrue);
    final snapshot = await replay.watch().first;
    expect(snapshot.tags['LI-101']!.value, 42);
    await replay.disconnect();
  });

  test('rejects unknown schema', () {
    expect(() => parser.parseReplay(valid.replaceFirst('"schemaVersion":1',
        '"schemaVersion":2')), throwsFormatException);
  });

  test('rejects duplicate tags', () {
    const duplicate = '{"schemaVersion":1,"frames":[{"observedAt":"2026-10-26T12:00:00Z",'
      '"tags":[{"id":"A","label":"A","value":1,"unit":""},'
      '{"id":"A","label":"A","value":2,"unit":""}]}]}';
    expect(() => parser.parseReplay(duplicate), throwsFormatException);
  });

  test('rejects nonfinite or invalid numeric values', () {
    expect(() => parser.parseReplay(valid.replaceFirst('"value":42.0',
        '"value":"42"')), throwsFormatException);
  });
}
