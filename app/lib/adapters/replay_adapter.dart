import 'dart:async';

import '../domain/plant_models.dart';
import 'plant_adapter.dart';

/// Reproduz snapshots previamente gravados, sem abrir rede ou dispositivo.
class ReplayAdapter implements PlantAdapter {
  ReplayAdapter(this.frames, {this.interval = const Duration(seconds: 1)})
    : assert(frames.isNotEmpty, 'Um replay precisa conter ao menos um frame.');

  final List<PlantSnapshot> frames;
  final Duration interval;

  @override
  String get displayName => 'Replay offline';

  @override
  bool get isReadOnly => true;

  @override
  Future<void> disconnect() async {}

  @override
  Stream<PlantSnapshot> watch() async* {
    for (final frame in frames) {
      yield frame;
      await Future<void>.delayed(interval);
    }
  }
}
