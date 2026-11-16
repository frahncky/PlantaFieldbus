# Sessão de 2026-11-16 — tentativa de comunicação System302 8.2 ↔ DF51

Registro da visita em que o notebook foi ligado por cabo Ethernet à PD3-302 e
o System302 8.2.2.1 foi configurado para tentar comunicar com o DF51.
Diferentemente das sessões anteriores, **esta sessão incluiu tráfego ativo de
leitura**, autorizado pelo operador no local: ping, busca HSE/SE do Syscon,
varredura Modbus TCP somente de leitura e diagnóstico pelo DFI Diver.

**Nada foi escrito no DF51 ou no DF65.** Não houve download, gravação de
firmware, RUN/HOLD, reset ou mudança de parâmetro.

## Resultado em uma frase

O notebook enxerga o DF51 (ping, anúncio UDP/4987, Modbus TCP/502 e DFI Diver),
mas o Syscon do System302 8.2.2.1 não estabelece comunicação de configuração —
nem em área HSE nem em área SE. A causa mais provável é o firmware
**DF51V3.7.5 de 17/10/2003**, muito anterior à linha 8.2 (a instalação local
traz `DF51V3.9.5`).

## Linha do tempo resumida

| Hora | Ação | Resultado |
| --- | --- | --- |
| 10:3x | `ipconfig` | Ethernet já estava em `192.168.164.20/24`, sem gateway; Wi-Fi em `192.168.1.101/24` |
| 10:36 | `ping 192.168.164.100` | 4/4 respostas, 7–18 ms, TTL 30 |
| 10:37 | System302 Settings → Workstation Role | Local, Configuration Server `127.0.0.1`, funções Engineering + Communication Server, NIC 1 = `192.168.164.20` |
| 10:51 | Syscon → nova **HSE Area** `PlantaDidatica` → On-line → Live List | Só aparece `HSE HOST 1` (o próprio notebook); DF51 ausente |
| 11:0x–11:3x | Firewall do Windows desativado pelo operador; métricas IPv4 ajustadas (Ethernet 5, Wi-Fi 50); On-line desligado/religado | DF51 continua ausente |
| 11:38 | Operador informa que o computador antigo usava `192.168.164.101` | — |
| 11:44 | System302 Settings: NIC 1 trocado para `192.168.164.101` | Ver erro de adaptador abaixo |
| 11:56 | `arp -a` | `.101` estava no **Topaz Loopback** (adaptador virtual), não na Ethernet; DF51 só visível na interface `.20` |
| 12:00 | `.101` removido do Topaz Loopback e adicionado à Ethernet (junto com `.20`) | DF51 continua respondendo ping pela Ethernet |
| 12:5x | Settings reaplicado com Studio302 fechado; Live List HSE | DF51 ausente |
| 13:44–13:56 | Captura Wireshark na Ethernet durante a Live List | Ver "Captura" |
| 14:00 | Operador informa que a estação original usava **System302 7.0.5** | — |
| 14:5x | Inventário somente leitura de `C:\Program Files (x86)\Smar` | Firmware `DF51V3.9.5*.ABS` presente; exemplos `DF51_HSE`/`DF51_SE` |
| 14:57–15:03 | Syscon → nova **Area** (SE) `PlantaDidaticaSE`, servidor `Smar.DFIOLEServer.0`, H1 `H1_Planta` com bridge `DF51` (Device Rev 07), On-line | `Communication initialization failure`; Live List desabilitada |
| 15:29 | `Test-NetConnection 192.168.164.100 -Port 502` | `TcpTestSucceeded: True` |
| 15:33–16:07 | Varredura Modbus TCP somente leitura (FC 01–04) | Unit ID 1 responde exceção 7 a tudo; IDs 2–247 sem resposta |
| 16:16 | Studio302 → Tools → System302 → **DFI Task Management (DFI Diver)** | `Model DF51 - SN# 1362`, firmware `DF51V3.7.5`, 17/10/2003, 3.761.154 bytes |

## Observado

### Identidade do controlador

- DFI Diver lista **`Model DF51 - SN# 1362`**.
- Firmware instalado: arquivo **`DF51V3.7.5`**, data **Fri Oct 17 08:46:12
  2003**, tamanho **3.761.154 bytes**. Aba *Messages* sem mensagens.
- MAC `00:30:5C:01:05:52`; o Wireshark resolve o OUI como `SMARLaborato`.
- LED **RUN aceso** no DF51; DF65 em **HOLD** (informado pelo operador).

### Captura (Wireshark, `wireshark_EthernetUJ9ZY3.pcapng`, ≈15 min)

- O notebook (`192.168.164.101`, MAC Dell `84:7b:eb:fb:b8:c4`) envia
  periodicamente *FMS Information Report Request* (FOUNDATION Fieldbus HSE)
  de UDP `1089` para o multicast `239.0.0.2:28000`, a cada ~5 s.
- O DF51 **nunca responde** a essas requisições.
- Os únicos 30 quadros do DF51 são o anúncio já conhecido:
  UDP `192.168.164.100:4987 → 255.255.255.255:4987`, a cada 30 s, payload com
  `DF51V3.7.5` e `Monitor 3302`.
- SHA-256 do arquivo: **não registrado** (arquivo permanece no notebook).

### Modbus TCP

- Porta TCP `502` aceita conexão.
- Unit ID `1`: toda leitura (FC 01, 02, 03, 04; endereços 0, 100, 1000, 4000)
  retorna **exceção 7 (Negative Acknowledge)**.
- Unit ID `0`: sem resposta (esperado — broadcast).
- Unit IDs `2–247`: sem resposta (timeout 0,5 s).

### Syscon 8.2.2.1

- Modo **HSE Area**: Live List mostra apenas `HSE HOST 1` com o IP da estação.
- Modo **Area (SE)** com `Smar.DFIOLEServer.0`: ao expandir o H1 com bridge
  DF51, `Communication initialization failure`; *Live List* fica desabilitada.
- Abrir o **System302 Settings** fecha Studio302/Syscon; reaplicar
  configuração com o Studio302 aberto falha com *"Can not change mode while
  Studio and some associated applications are running"*.
- Studio302/Syscon/System302 Settings rodam elevados; o controle remoto da
  tela só funcionou depois de o app de controle também rodar elevado.

### Inventário somente leitura da instalação (`C:\Program Files (x86)\Smar`)

- Firmware do DF51 disponível em `FBTools\`:
  `DF51V3.9.5.ABS` (4.276.594 B), `DF51V3.9.5R.ABS` (4.425.921 B),
  `DF51VCF3.9.5.ABS` (4.276.031 B), `DF51VCF3.9.5R.ABS` (4.425.354 B),
  `DF51FBViewEth008.ABS` (3.846.460 B).
- Ferramentas: `FBTools\Dfi Download.exe`, `FBTools\DfiDiver.exe`,
  `FBTools\dfbatch\Firmware\` (sem arquivos DF51 nessa pasta).
- Exemplos de fábrica: `Syscon\Samples\DFI302\DF51_HSE\DF51_HSE.ffp` e
  `DF51_SE\DF51_SE.ffp`.
- Ferramentas do DF65 presentes: `FBTools\DF65Tools\`, `Logic View`,
  `OleServers\DF65Svr\`.

## Inferido

- O canal Smar proprietário usado pelo DFI Diver e pelo anúncio UDP/4987 está
  funcional; o problema não é cabo, IP, firewall ou escolha de NIC.
- O DF51 com firmware de 2003 não implementa (ou não responde a) a descoberta
  HSE usada pelo Syscon 8.2, e o servidor SE do 8.2 também não inicializa
  comunicação com ele. Incompatibilidade de versão é a explicação mais
  coerente, consistente com a matriz do manual DFI302 que lista `V3.9.5` para
  System302 7.0–8.2.
- Modbus TCP: servidor ativo no Unit ID 1, mas **sem mapa configurado**
  (blocos MBCF/MBSS ausentes ou inativos). Não há dados de processo
  disponíveis por Modbus sem configurar o DF51.
- `R` em `DF51V3.9.5R.ABS` provavelmente indica redundância; o significado de
  `VCF` é desconhecido.

## Desconhecido

- Qual dos arquivos `DF51*3.9.5*.ABS` é o correto para o SN# 1362.
- Se a atualização para 3.9.5 apaga a configuração atual do DF51.
- Se a configuração atual do DF51/DF65 tem valor de recuperação (não há backup).
- Se o System302 7.0.5 (estação original) ainda existe no computador antigo.
- Hash do pcap desta sessão.

## Estado em que o notebook ficou (para reverter)

| Item | Antes | Agora | Como reverter |
| --- | --- | --- | --- |
| Ethernet IPv4 | `192.168.164.20/24` | `192.168.164.20/24` **e** `192.168.164.101/24` | `Remove-NetIPAddress -IPAddress 192.168.164.101 -Confirm:$false` |
| Topaz Loopback IPv4 | `54.232.189.113` (antes da sessão o operador colocou `.101` nele) | APIPA `169.254.253.104` | Recolocar `54.232.189.113` se o aplicativo do banco reclamar |
| Métrica IPv4 | automática | Ethernet 5, Wi-Fi 50 | `Set-NetIPInterface -InterfaceAlias "Ethernet" -AutomaticMetric Enabled`; idem `"Wi-Fi"` |
| Firewall do Windows | ativo | desativado temporariamente pelo operador | Reativar em Segurança do Windows |
| System302 Settings, NIC 1 | `192.168.164.20` | `192.168.164.101` | Workstation Role → IP address and Server role |
| Projetos Syscon | — | `PlantaDidatica` (HSE) e `PlantaDidaticaSE` (SE, com H1 + bridge DF51) criados localmente | Apagar em `ConfigurationWorkspace\Client\CWFiles\System302\` se não forem úteis |
| Wireshark | — | `wireshark_EthernetUJ9ZY3.pcapng` | Arquivar fora do Git e registrar SHA-256 |

## Caminhos avaliados

1. **Atualizar o firmware do DF51 para 3.9.5** pelo *Firmware Download (FB
   Tools Wizard)* — caminho natural para usar o System302 8.2, mas grava o
   controlador e provavelmente apaga sua configuração. Requer confirmação SMAR
   do arquivo e autorização específica (ver `AGENTS.md`).
2. **Usar o ambiente da época** — computador antigo com System302 7.0.5,
   acesso remoto a ele, clone por Disk2vhd em máquina virtual, ou instalador
   7.0.5 obtido com o fornecedor/SMAR. Não altera a planta.
3. **Modbus TCP** — exige configurar blocos Modbus no DF51; depende de 1 ou 2.
4. **DF65 por Modbus RTU serial** — possível caminho paralelo para ler a lógica
   ladder; não testado.

## Próximo gate

Enviar `docs/pedido-suporte-smar.md` atualizado e decidir entre os caminhos 1
e 2. Nenhuma gravação de firmware sem: confirmação SMAR do arquivo, tentativa
de salvar a configuração atual e autorização explícita registrada.
