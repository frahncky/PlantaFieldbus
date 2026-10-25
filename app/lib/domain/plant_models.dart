class PlantTag {
  const PlantTag({
    required this.id,
    required this.label,
    required this.value,
    required this.unit,
    required this.observedAt,
  });

  final String id;
  final String label;
  final double value;
  final String unit;
  final DateTime observedAt;
}

class PlantEvent {
  const PlantEvent({
    required this.time,
    required this.message,
    required this.severity,
  });

  final DateTime time;
  final String message;
  final EventSeverity severity;
}

enum EventSeverity { info, warning, alarm }

class PlantSnapshot {
  const PlantSnapshot({required this.tags, required this.events});

  final Map<String, PlantTag> tags;
  final List<PlantEvent> events;
}
