# Levantamento mínimo para habilitar leitura da planta real

Este projeto **não sabe ainda** qual interface Ethernet da bancada comunica com o processo. O perfil FOUNDATION Fieldbus H1, por si só, não significa que um cliente possa ler tags usando HSE, Modbus TCP ou OPC UA.

## Coleta do laboratório (sem alterar a planta)

- Fotografe etiqueta do controlador, gateway/bridge e interface Ethernet (modelo, revisão e fabricante).
- Registre o software que hoje mostra os valores da planta e sua versão.
- Identifique a porta física em uso e se existe servidor OPC, gateway ou bridge já configurado.
- Com autorização e sem interromper o processo, capture tráfego Ethernet passivamente usando o fluxo documentado em `docs/captura-passiva.md`. Não executar scanner ou tentar endereços por tentativa.
- Traga apenas o relatório sanitizado produzido por `scripts/Analyze-Pcap.ps1`, não credenciais nem captura bruta de rede.

## Critério para escolher um adaptador

| Evidência confirmada | Alternativa técnica |
| --- | --- |
| Servidor OPC UA existente | Cliente OPC UA, sessões e leitura de nós explicitamente permitidos |
| Servidor OPC DA legado existente | Ponte Windows OPC DA para serviço local somente leitura |
| Gateway expõe Modbus TCP | Cliente Modbus TCP, apenas FC03/FC04 e mapa de registradores confirmado |
| Gateway FOUNDATION Fieldbus HSE suportado | Adaptador específico conforme documentação e topologia do fornecedor |
| Apenas FOUNDATION Fieldbus H1 presente | Necessária interface/gateway compatível; não é socket IP direto |

Se não existir evidência de uma opção acima, manter conexão desabilitada.

## Critérios de aceitação para a primeira leitura

1. IP/hostname, porta e protocolo comprovados por documentação e captura.
2. Mapa de tags aprovado com escala, unidades, datatype e permissões.
3. Ensaios offline reprodutíveis antes de conectar à rede.
4. Operação explicitamente iniciada pelo técnico em bancada isolada; sem conexão automática ao abrir o programa.
5. Leitura de uma tag real com timestamp, qualidade, valor e unidade, acompanhada de timeout e recuperação de desconexão.
6. Log auditável, credenciais em armazenamento seguro e nenhuma escrita de variável/setpoint.

A presença de código de adaptador em uma branch não significa que a planta esteja conectada.
