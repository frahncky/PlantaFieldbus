class TopologyNode {
  const TopologyNode({
    required this.id,
    required this.label,
    required this.kind,
    this.address,
  });

  final String id;
  final String label;
  final String kind;
  final String? address;
}

class ObservedTopology {
  const ObservedTopology({
    required this.captureName,
    required this.captureSha256,
    required this.nodes,
  });

  final String captureName;
  final String captureSha256;
  final List<TopologyNode> nodes;
}
