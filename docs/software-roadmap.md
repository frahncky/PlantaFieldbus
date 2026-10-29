# Sequência automática — novo software

## Entregue agora

1. Aplicação Flutter para Windows em `app/`.
2. Painel operacional em modo de simulação local.
3. Sinótico inicial, leituras simuladas e navegação para topologia, histórico e conexão.
4. Escrita em PLC bloqueada por projeto.

## Próximas etapas automáticas permitidas

1. Separar simulador, modelos de tags e histórico em uma camada de domínio. — concluído
2. Persistir histórico e eventos simulados localmente. — base JSON concluída
3. Criar interfaces somente leitura para `Simulation`, `OPC`, `Modbus TCP` e `HSE`. — contratos concluídos; adaptadores reais permanecem inativos
4. Implementar testes com replay para os adaptadores; os reais permanecem inativos até haver evidência de protocolo. — concluído para snapshots offline
5. Importar a topologia observada da captura passiva. — concluído: a tela importa um `network-summary.json` local sem estabelecer conexões.
6. Histórico e alarmes locais do simulador. — concluído: mantém os últimos eventos na interface e grava cache JSON local.
7. Designer inicial do sinótico. — concluído: prévia local e controles de visibilidade dos elementos demonstrativos.
8. Decodificação de anúncios UDP observados. — concluída para replay offline; a escuta passiva fica desativada até início explícito do operador.

## Evidência validada em campo

- DF51/DFI302 confirmado por anúncio UDP, ARP e um único teste ICMP.
- Endereço observado: `192.168.164.100`, MAC `00:30:5C:01:05:52`, UDP 4987.
- A interface WPF mostra esse inventário e replica os comandos visíveis do
  painel físico apenas como botões bloqueados.

## Gates obrigatórios

- Sem instalação ou execução do software legado.
- Sem descoberta ativa, varredura ou alteração de rede.
- Sem conexão de protocolo industrial com PLC antes da identificação do adaptador.
- Sem escrita sem autorização explícita e laboratório.
