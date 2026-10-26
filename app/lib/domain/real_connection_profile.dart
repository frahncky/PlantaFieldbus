/// Perfil de integração somente leitura, sem execução de tráfego.
enum PlantProtocol { opcUa, opcDa, modbusTcp, foundationHse }

enum EvidenceKind { equipmentLabel, passiveCapture, approvedProtocol }

class IntegrationEvidence {
  const IntegrationEvidence({required this.kind, required this.reference});
  final EvidenceKind kind;
  final String reference;
}

class PlantConnectionProfile {
  const PlantConnectionProfile({
    required this.controllerModel,
    required this.protocol,
    required this.endpoint,
    required this.evidence,
    this.operatorApproved = false,
  });

  final String controllerModel;
  final PlantProtocol protocol;
  /// Endereço meramente descritivo: nunca abrir socket neste módulo.
  final String endpoint;
  final List<IntegrationEvidence> evidence;
  final bool operatorApproved;

  List<String> validateForReadOnlyReview() {
    final issues = <String>[];
    if (controllerModel.trim().isEmpty) {
      issues.add('Identificar modelo e variante do controlador/gateway.');
    }
    if (endpoint.trim().isEmpty) {
      issues.add('Registrar endpoint identificado em documentação ou captura.');
    }
    for (final kind in EvidenceKind.values) {
      if (!evidence.any((e) => e.kind == kind && e.reference.trim().isNotEmpty)) {
        issues.add('Evidência obrigatória ausente: ${kind.name}.');
      }
    }
    if (!operatorApproved) {
      issues.add('Aguardando revisão humana e autorização de leitura em laboratório.');
    }
    return issues;
  }

  bool get readyForReviewOnly => validateForReadOnlyReview().isEmpty;
}

/// Não cria conexões, não descobre hosts e não autoriza escrita.
/// A aprovação do perfil NÃO ativa adaptadores reais automaticamente.
class RealConnectionGate {
  const RealConnectionGate();

  bool canActivate(PlantConnectionProfile profile) => false;

  Never rejectActivation() => throw StateError(
    'Integração real desativada: falta implementar e validar adaptador '
    'somente leitura em bancada isolada.',
  );
}
