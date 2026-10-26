import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:planta_fieldbus_app/domain/ethernet_discovery_beacon.dart';

void main() {
  const parser = EthernetDiscoveryBeaconParser();

  test('parses identity fields from a recorded discovery payload', () {
    final payload = Uint8List.fromList(<int>[
      0x00,
      0xe9,
      0x03,
      0x00,
      0x52,
      0x05,
      0x00,
      0x00,
      ...latin1.encode('DF51V3.7.5   '),
      0x00,
      0x00,
      ...latin1.encode('Monitor 3302'),
    ]);

    final beacon = parser.tryParse(payload);

    expect(beacon?.firmware, '3.7.5');
    expect(beacon?.monitor, '3302');
  });

  test('ignores a datagram without the observed identity markers', () {
    expect(parser.tryParse(Uint8List.fromList([1, 2, 3])), isNull);
  });
}
