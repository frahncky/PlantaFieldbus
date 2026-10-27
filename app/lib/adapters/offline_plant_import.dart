import 'dart:convert';

import '../domain/plant_models.dart';
import 'replay_adapter.dart';

/// Creates an offline replay from an explicitly exported JSON document.
/// No socket, device discovery, fieldbus client, or write operation is used.
class OfflinePlantImport {
  const OfflinePlantImport();

  ReplayAdapter parseReplay(String jsonText) {
    final document = jsonDecode(jsonText);
    if (document is! Map<String, dynamic>) {
      throw const FormatException('Root must be a JSON object.');
    }
    final schema = document['schemaVersion'];
    if (schema != 1) {
      throw const FormatException('Unsupported schemaVersion.');
    }
    final rawFrames = document['frames'];
    if (rawFrames is! List || rawFrames.isEmpty || rawFrames.length > 10000) {
      throw const FormatException('frames must contain 1 to 10000 records.');
    }
    final frames = <PlantSnapshot>[];
    DateTime? previous;
    for (final rawFrame in rawFrames) {
      if (rawFrame is! Map<String, dynamic>) {
        throw const FormatException('Invalid frame.');
      }
      final timestamp = DateTime.tryParse(rawFrame['observedAt']?.toString() ?? '');
      if (timestamp == null) throw const FormatException('Invalid observedAt.');
      if (previous != null && timestamp.isBefore(previous)) {
        throw const FormatException('Frames must be ordered chronologically.');
      }
      previous = timestamp;
      final rawTags = rawFrame['tags'];
      if (rawTags is! List || rawTags.isEmpty || rawTags.length > 512) {
        throw const FormatException('Each frame needs 1 to 512 tags.');
      }
      final tags = <String, PlantTag>{};
      for (final raw in rawTags) {
        if (raw is! Map<String, dynamic>) throw const FormatException('Invalid tag.');
        final id = raw['id'];
        final label = raw['label'];
        final unit = raw['unit'];
        final value = raw['value'];
        if (id is! String || id.trim().isEmpty || id.length > 128 ||
            label is! String || label.trim().isEmpty || label.length > 256 ||
            unit is! String || unit.length > 32 ||
            value is! num || !value.toDouble().isFinite ||
            tags.containsKey(id)) {
          throw const FormatException('Invalid or duplicate tag.');
        }
        tags[id] = PlantTag(
          id: id,
          label: label,
          value: value.toDouble(),
          unit: unit,
          observedAt: timestamp,
        );
      }
      frames.add(PlantSnapshot(tags: tags, events: const []));
    }
    return ReplayAdapter(frames);
  }
}
