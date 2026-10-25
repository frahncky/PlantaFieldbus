import 'dart:convert';

import '../domain/topology_models.dart';

/// Lê somente o JSON produzido por `scripts/Analyze-Pcap.ps1`.
/// Não abre PCAP, não descobre hosts e não estabelece conexões.
class NetworkSummaryImporter {
  ObservedTopology importJson(String contents) {
    final document = jsonDecode(contents) as Map<String, dynamic>;
    final endpointLines = (document['ip_endpoints'] as List<dynamic>? ?? [])
        .whereType<String>();
    final addresses = <String>{};
    final expression = RegExp(r'\b(?:\d{1,3}\.){3}\d{1,3}\b');

    for (final line in endpointLines) {
      addresses.addAll(
        expression.allMatches(line).map((match) => match.group(0)!),
      );
    }

    final nodes =
        addresses
            .map(
              (address) => TopologyNode(
                id: 'ip:$address',
                label: address,
                kind: 'endpoint-observado',
                address: address,
              ),
            )
            .toList()
          ..sort((left, right) => left.address!.compareTo(right.address!));

    return ObservedTopology(
      captureName: document['capture'] as String? ?? 'captura-desconhecida',
      captureSha256: document['sha256'] as String? ?? '',
      nodes: nodes,
    );
  }
}
