import 'package:flutter_test/flutter_test.dart';
import 'package:planta_fieldbus_app/services/network_summary_importer.dart';

void main() {
  test('imports only observed IPv4 endpoints from an offline summary', () {
    const summary = '''
      {"capture":"segunda-feira.pcapng","sha256":"abc123","ip_endpoints":["  10.0.0.8  20 packets","  10.0.0.24  20 packets"," invalid "]}
    ''';

    final topology = NetworkSummaryImporter().importJson(summary);

    expect(topology.captureName, 'segunda-feira.pcapng');
    expect(topology.captureSha256, 'abc123');
    expect(topology.nodes.map((node) => node.address), [
      '10.0.0.24',
      '10.0.0.8',
    ]);
  });
}
