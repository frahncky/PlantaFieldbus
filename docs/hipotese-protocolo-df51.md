# Hipótese de protocolo — DF51

Este documento separa identidade observada, capacidades presentes no software
local e protocolo efetivamente confirmado. Ele não autoriza conexão ativa,
varredura, alteração de rede, download ou mudança RUN/HOLD.

## Matriz de evidências

| Fonte | Fato observado | O que demonstra | O que não demonstra |
| --- | --- | --- | --- |
| Captura passiva de 2026-11-11 | `192.168.164.100:4987` envia broadcast UDP para `255.255.255.255:4987`, MAC `00:30:5C:01:05:52` | Há um equipamento anunciante no segmento e o anúncio se identifica como `DF51V3.7.5` / `Monitor 3302` | Que UDP/4987 aceite consulta, qual seja a máscara, ou que haja leitura de processo nesse porto |
| Inventário do rack | DF51 é controlador Ethernet/4 H1; DF65 é coprocessador lógico | A identidade anunciada é compatível com a arquitetura declarada | Projeto instalado, tags, E/S, intertravamentos ou estado operacional atual |
| `FbusComm.dll` estático | Há famílias `ReadParameterReq`, `ReadObjectReq`, `LiveListReq`, bem como chamadas de escrita | O System302 instalado contém uma pilha capaz de leitura e alteração | Que a instalação local esteja configurada para este DF51, o transporte utilizado, a porta, ou a semântica das requisições |
| `NetConfDownloader.exe` estático | Referências a `Connect`, `Download` e `WriteChannelGuid` para AS-i/Modbus | É um caminho com potencial de alteração de configuração | Um caminho de leitura do DF51 ou meio seguro de recuperar o projeto |
| Live List HSE do Syscon 8.2 (2026-11-16) | Estação envia *FMS Information Report Request* UDP 1089 → `239.0.0.2:28000`; DF51 não responde | O DF51 V3.7.5 não participa da descoberta HSE do System302 8.2 | Que o DF51 não tenha HSE em outra versão de firmware |
| Area SE do Syscon 8.2 (2026-11-16) | `Smar.DFIOLEServer.0` → `Communication initialization failure` | O servidor SE do 8.2 também não inicializa sessão com este DF51 | A causa exata (versão, licença ou configuração) |
| DFI Diver (2026-11-16) | `DF51 - SN# 1362`, `DF51V3.7.5`, 17/10/2003 | Existe canal Smar proprietário funcional entre estação e DF51 | O transporte/porta desse canal (provavelmente ligado ao UDP/4987, não confirmado) |
| Modbus TCP (2026-11-16) | TCP/502 aberto; Unit ID 1 → exceção 7 em FC 01–04 | Servidor Modbus ativo sem mapa de registradores | Dados de processo; exige configurar blocos Modbus no DF51 |

## Correlação resultante

A única correlação sustentada é: o anúncio de rede identifica um DF51 e a
instalação local do System302 possui componentes que, em tese, sabem trabalhar
com equipamentos Fieldbus. Não há vínculo observado entre o datagrama UDP/4987
e `FbusComm.dll`, nem há pacote de sessão, resposta de leitura, log do
Communication Server ou documentação que transforme esta hipótese em protocolo
confirmado.

Portanto, `UDP/4987` é classificado como **anúncio de identidade passivo**. Não
é um endpoint de engenharia, processo ou troca de estado documentado neste
projeto.

## Artefatos de referência

- Captura: SHA-256
  `6ea90e63689468e18a426befad50108bc90055c89ee36e7db46c4eec60b43788`.
- `FbusComm.dll`: SHA-256
  `70052383e1acab15ce6f35a65bd8976177314cce1bf7e51e1be445c385f6b104`.
- `NetConfDownloader.exe`: SHA-256
  `95ccac48b16190ef7f381c2279d8b189ef9edd2818069f62f196daeab8f98741`.
- Evidências REA: `ev_30b763dca7d11f5788385dc3fcd0d433e28cb019634c25c42bae9db9657bc6cf`,
  `ev_2452d1ffbdb2783d69eb8ad49ebf65df150209501dc2108634f12b87cf63b3d2`.

## Próximo gate obrigatório

Uma pessoa deve aprovar uma fonte adicional e verificável antes da fase de
cliente: documentação SMAR correspondente ao DF51 v3.7.5, backup/projeto
identificado da bancada, ou captura de uma sessão oficial de leitura já
existente. Depois disso, o primeiro artefato técnico será um replay offline
somente de leitura — nunca tráfego para a planta.


## Auditoria do aplicativo local

Em 2026-11-11, a revisão do código confirmou que os adaptadores `OPC`,
`Modbus TCP` e `HSE` são instâncias indisponíveis que somente retornam erro de
uso; não possuem implementação de conexão ou escrita. O `ReplayAdapter` lê
quadros já preservados sem abrir rede. `PassiveEthernetDiscovery` só cria um
socket UDP após acionamento explícito do operador e sua implementação apenas
recebe datagramas (`receive`), sem `send`, TCP, broadcast de descoberta ou
comando de PLC.

Isso confirma o limite do aplicativo atual, não a comunicação com o DF51. A
suíte offline foi executada com sucesso: 6 testes passaram.
