import 'dart:async';
import 'dart:io';

import '../domain/ethernet_discovery_beacon.dart';

/// Escuta anúncios UDP já presentes na rede. Não envia datagramas, não abre
/// TCP e não faz descoberta ativa. Deve ser iniciado explicitamente pelo
/// operador em ambiente autorizado.
class PassiveEthernetDiscovery {
  PassiveEthernetDiscovery({
    this.udpPort = 4987,
    EthernetDiscoveryBeaconParser? parser,
  }) : _parser = parser ?? const EthernetDiscoveryBeaconParser();

  final int udpPort;
  final EthernetDiscoveryBeaconParser _parser;
  RawDatagramSocket? _socket;

  Future<Stream<EthernetDiscoveryBeacon>> start() async {
    if (_socket != null) {
      throw StateError('A escuta passiva já está em execução.');
    }

    final socket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      udpPort,
      reuseAddress: true,
    );
    _socket = socket;
    final controller = StreamController<EthernetDiscoveryBeacon>(
      onCancel: stop,
    );

    socket.listen(
      (event) {
        if (event != RawSocketEvent.read) return;
        final datagram = socket.receive();
        if (datagram == null) return;
        final beacon = _parser.tryParse(datagram.data);
        if (beacon != null && !controller.isClosed) controller.add(beacon);
      },
      onError: controller.addError,
      onDone: controller.close,
    );

    return controller.stream;
  }

  Future<void> stop() async {
    _socket?.close();
    _socket = null;
  }
}
