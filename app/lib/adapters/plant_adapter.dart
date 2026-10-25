import '../domain/plant_models.dart';

abstract interface class PlantAdapter {
  String get displayName;
  bool get isReadOnly;
  Stream<PlantSnapshot> watch();
  Future<void> disconnect();
}

class UnavailableAdapter implements PlantAdapter {
  const UnavailableAdapter(this.displayName);

  @override
  final String displayName;

  @override
  bool get isReadOnly => true;

  @override
  Future<void> disconnect() async {}

  @override
  Stream<PlantSnapshot> watch() =>
      Stream.error(UnsupportedError('$displayName ainda não foi habilitado.'));
}

class OpcAdapter extends UnavailableAdapter {
  const OpcAdapter() : super('OPC (aguardando confirmação)');
}

class ModbusTcpAdapter extends UnavailableAdapter {
  const ModbusTcpAdapter() : super('Modbus TCP (aguardando confirmação)');
}

class HseAdapter extends UnavailableAdapter {
  const HseAdapter() : super('HSE (aguardando confirmação)');
}
