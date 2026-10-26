import 'dart:convert';
import 'dart:typed_data';

/// Identidade anunciada por um datagrama de descoberta observado na rede.
///
/// Esta classe não representa uma sessão de controle e não contém operações de
/// escrita. Os campos são extraídos somente quando aparecem como texto no
/// payload observado.
class EthernetDiscoveryBeacon {
  const EthernetDiscoveryBeacon({
    required this.firmware,
    required this.monitor,
  });

  final String firmware;
  final String monitor;
}

class EthernetDiscoveryBeaconParser {
  const EthernetDiscoveryBeaconParser();

  EthernetDiscoveryBeacon? tryParse(Uint8List payload) {
    final text = latin1.decode(payload, allowInvalid: true);
    final firmware = RegExp(r'DF51V([0-9]+(?:\.[0-9]+)*)').firstMatch(text);
    final monitor = RegExp(r'Monitor\s+([0-9]+)').firstMatch(text);

    if (firmware == null || monitor == null) return null;
    return EthernetDiscoveryBeacon(
      firmware: firmware.group(1)!,
      monitor: monitor.group(1)!,
    );
  }
}
