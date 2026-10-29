import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:planta_fieldbus_app/domain/ethernet_discovery_beacon.dart';

void main() {
  const parser = EthernetDiscoveryBeaconParser();

  test('parses identity fields from the recorded UDP discovery payload', () {
    final payload = Uint8List.fromList(<int>[
      0x00,
      0xe9,
      0x03,
      0x00,
      0x52,
      0x05,
      0x00,
      0x00,
      0x01,
      0x00,
      0x84,
      0xd6,
      0x8f,
      0x3f,
      0xff,
      0xff,
      0xff,
      0xff,
      0x02,
      0x44,
      0x46,
      0x35,
      0x31,
      0x56,
      0x33,
      0x2e,
      0x37,
      0x2e,
      0x35,
      0x20,
      0x20,
      0x20,
      0x20,
      0x20,
      0xe6,
      0x0c,
      0x00,
      0x00,
      0x4d,
      0x6f,
      0x6e,
      0x69,
      0x74,
      0x6f,
      0x72,
      0x20,
      0x33,
      0x33,
      0x30,
      0x32,
    ]);

    final beacon = parser.tryParse(payload);

    expect(beacon?.firmware, '3.7.5');
    expect(beacon?.monitor, '3302');
  });

  test('ignores a datagram without the observed identity markers', () {
    expect(parser.tryParse(Uint8List.fromList([1, 2, 3])), isNull);
  });
}
