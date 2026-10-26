import 'package:flutter_test/flutter_test.dart';
import 'package:planta_fieldbus/domain/real_connection_profile.dart';

void main() {
  test('perfil sem evidências permanece pendente', () {
    final profile = PlantConnectionProfile(
      controllerModel: '',
      protocol: PlantProtocol.foundationHse,
      endpoint: '',
      evidence: const [],
    );
    expect(profile.readyForReviewOnly, isFalse);
    expect(profile.validateForReadOnlyReview(), hasLength(5));
  });

  test('evidências completas permitem apenas revisão, não conexão', () {
    final profile = PlantConnectionProfile(
      controllerModel: 'Gateway confirmado em laboratório',
      protocol: PlantProtocol.foundationHse,
      endpoint: 'Identificado no PCAP',
      operatorApproved: true,
      evidence: const [
        IntegrationEvidence(kind: EvidenceKind.equipmentLabel, reference: 'foto-001'),
        IntegrationEvidence(kind: EvidenceKind.passiveCapture, reference: 'pcap-sha256'),
        IntegrationEvidence(kind: EvidenceKind.approvedProtocol, reference: 'revisao-001'),
      ],
    );
    expect(profile.readyForReviewOnly, isTrue);
    expect(const RealConnectionGate().canActivate(profile), isFalse);
    expect(() => const RealConnectionGate().rejectActivation(), throwsStateError);
  });
}
