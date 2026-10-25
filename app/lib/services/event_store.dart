import 'dart:convert';
import 'dart:io';

import '../domain/plant_models.dart';

class JsonEventStore {
  JsonEventStore(this.file);

  final File file;

  Future<void> append(PlantEvent event) async {
    final events = await read();
    events.add(event);
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(events.map(_encode).toList()));
  }

  Future<List<PlantEvent>> read() async {
    if (!await file.exists()) return [];
    final decoded = jsonDecode(await file.readAsString()) as List<dynamic>;
    return decoded
        .cast<Map<String, dynamic>>()
        .map(
          (item) => PlantEvent(
            time: DateTime.parse(item['time'] as String),
            message: item['message'] as String,
            severity: EventSeverity.values.byName(item['severity'] as String),
          ),
        )
        .toList();
  }

  Map<String, String> _encode(PlantEvent event) => {
    'time': event.time.toIso8601String(),
    'message': event.message,
    'severity': event.severity.name,
  };
}
