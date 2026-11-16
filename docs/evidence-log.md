# Registro de evidências

## 2026-11-16 — instrumentos, valores on-line, OPC e DF65 (somente leitura)

### Contexto

Continuação da sessão com o operador na bancada. Apenas visualização de
atributos, caracterização on-line sem edição, TagView e exportação local.
Nenhum comissionamento, download, mudança de modo ou escrita foi feito.

### Observado

- `FIT-31`: Smar **LD302**, Dev/DD/CF `03/02/01`, ID
  `0003020001:SMAR-LD302:000810463`.
- `TIT-31`: Smar **TT302**, Dev/DD/CF `03/02/01`, ID
  `0003020002:SMAR-TT302:004808101`.
- Nos dois, o menu oferece *Commission* e não *Decommission*, e o FB VFD não
  tem blocos. No `LIT-31` ocorre o inverso (comissionado, com blocos `RES1`,
  `TRD1`, `DIAG-1`, `AI1`, `ALM1`).
- A caracterização on-line de `LIT-31_AI1` lista `MODE_BLK`, `BLOCK_ERR`,
  `PV`, `OUT`, `XD_SCALE`, `OUT_SCALE`, `CHANNEL`, `L_TYPE`, `HI_LIM`,
  `LO_LIM` etc., mas nenhum valor é retornado, mesmo com *Refresh all
  parameters value*. O log de comunicação não mostra erros de leitura.
- TagView + `Smar.DfiOleServer.0`: conecta, mas só expõe
  `#SE_DIAG_SYSTEM302` (`SE_CLIENTS`, `SE_SOURCE1`, `SE_SOURCE2`).
- `Export → Consolidate OPC Database` falha com `Write access denied to user
  MicrosoftAccount\<usuário>`, inclusive com Studio302 como administrador,
  login de segurança do System302 desativado e permissão *Modificar* em
  `C:\Program Files (x86)\Smar`.
- LogicView 8.2.2: opção **DF65 Logic** desabilitada.
- TagView + `Smar.DF65Server.1` (`df65svr2.exe`, build 8051006): o processo
  inicia com janela vazia e a conexão retorna `Error connecting to OPC
  server`.
- Existe na estação um projeto `PlantaDidaticaSE` criado às 16:57, de origem
  não registrada nesta sessão.

### Inferido

- `FIT-31` e `TIT-31` estão presentes no barramento mas não comissionados;
  as medições de vazão e temperatura correspondentes provavelmente não
  alimentam a estratégia.
- A ausência de valores on-line é coerente com incompatibilidade entre o
  System302 8.2.2 e o DF51 `V3.7.5` (falta de *device support*), e não com
  falha física.
- O servidor OPC do DF65 não tem configuração de rota/tags; a configuração
  esperada vem do projeto LogicView do DF65, ausente.

### Desconhecido

- Causa exata do bloqueio do Consolidate OPC Database.
- Se o DF65 está em HOLD por parada manual ou por perda de programa.
- Conteúdo do projeto `PlantaDidaticaSE`.

### Próximo gate

Localizar o PC antigo com System302 7.0.5 (projeto ladder do DF65, *device
support* e servidor OPC configurados) ou obter orientação da SMAR conforme
`docs/pedido-suporte-smar.md`. Comissionar `FIT-31`/`TIT-31` e colocar o DF65
em RUN continuam bloqueados até que a estratégia e o programa sejam conhecidos.

## 2026-11-16 — upload somente leitura da configuração do DF51 (Syscon SE)

### Contexto

Feito com o operador presente na bancada, pelo Syscon do System302 v8.2.2 SP1
no notebook. Foram usados apenas **Upload** (leitura do equipamento para o
projeto local) e **On Line Characterization** sem edição. Nenhum Download,
mudança de modo de bloco, escrita de parâmetro, RUN/HOLD ou alteração de rede
foi feito.

### Observado

- Estado físico informado pelo operador: **DF51 em RUN** e **DF65 em HOLD**.
- O projeto existente `PlantaDidatica` usa `Smar.HSEOLEServer.0`; nesse modo
  a HSE Live List mostrou apenas `HSE HOST 1` em `192.168.164.101` (o próprio
  notebook). O DF51 não aparece em HSE.
- Um projeto novo do tipo Area (SE), `PlantaSE_Leitura`, com
  `Smar.DFIOLEServer.0`, encontrou o controlador. O upload de topologia, lista
  de equipamentos e lista de blocos retornou:
  - controlador **DFI-PD3** com 4 canais Fieldbus;
  - blocos no DFI-PD3: `DFI-PD3_RES1`, `DFI-TRD-1362`, `DFI-PD3-DIAG-1`,
    `DFI-PD3_MBCF1`, `DFI-PD3_MBCM1`, `DFI-PD3_MBCM2`;
  - **Fieldbus 1**: `LIT-31`, `FY-31`, `FIT-32`, `FY-32`, `TIT-32`, `FIT-31`,
    `TIT-31` (`FIT-31` e `TIT-31` com marcador vermelho de alerta);
  - **Fieldbus 2, 3 e 4**: somente o DFI-PD3, sem equipamentos de campo.
- O log de comunicação registrou `Block creation failure during upload` para
  `FB VFD`.
- A caracterização on-line de `DFI-PD3_MBCM1` identifica o bloco como
  *ModBus Control Master* e lista `MODE_BLK`, `BLOCK_ERR`, `LOCAL_MOD_MAP`,
  `BAD_STATUS`, `IN_1..4`, `IN_D1..D4`, `OUT_1..4`, `OUT_D1..D4`, mas todos os
  valores ficaram em branco, mesmo após atualização.
- O projeto `PlantaSE_Leitura` foi salvo localmente no notebook (sem os valores
  de parâmetros, que não foram incluídos no upload).

### Inferido

- O DF51 roda firmware **SE**, não HSE; por isso só é visível pelo
  `DFIOLEServer`.
- O DF51 atua como **mestre** Modbus (MBCF + MBCM) e não possui blocos de
  escravo (MBSS/MBCS). Isso explica a exceção 07 a todas as leituras do
  QModMaster registradas na entrada anterior.
- O parceiro Modbus dos MBCM é provavelmente o DF65; com o DF65 em HOLD, a
  lógica ladder não executa e esse intercâmbio deve estar falhando.
- Os valores vazios e a falha de criação de blocos indicam falta de *device
  support* no notebook para a versão de firmware do DF51.

### Desconhecido

- Parâmetros do MBCF1/MBCM1/MBCM2 (escravo, endereços, status, erros).
- Conteúdo do programa ladder do DF65 e efeito de colocá-lo em RUN.
- Causa do alerta em `FIT-31` e `TIT-31`.

### Próximo gate

Importar no Syscon (File → Import Device Support) o *device support* do DF51
compatível com o firmware 3.7.5, obtido do PC antigo (System302 7.0.5) ou da
SMAR, e repetir o upload incluindo parâmetros. Colocar o DF65 em RUN continua
bloqueado até o programa ladder ser conhecido, conforme `AGENTS.md`.

## 2026-11-16 — teste Modbus TCP somente leitura no DF51 (QModMaster)

### Contexto

Teste ativo, solicitado e acompanhado pelo operador no laboratório, feito com
o QModMaster (mestre Modbus) a partir do notebook ligado à bancada. Foram
usadas **apenas funções de leitura** (FC01, FC03 e FC04). Nenhuma função de
escrita, comando RUN/HOLD, download ou alteração de configuração foi enviada
ao DF51.

### Observado

- A conexão TCP com `192.168.164.100:502` foi aceita: o DF51 mantém um
  servidor Modbus TCP escutando na porta 502.
- Respostas registradas no Bus Monitor (endereço Modbus no quadro, base 0):

| Hora | Unit ID | Função | Endereço / qtd. | Quadro enviado | Resposta |
| --- | :---: | --- | --- | --- | --- |
| 19:07:23 | 1 | FC03 Read Holding Registers | 0 / 10 | `00 01 00 00 00 06 01 03 00 00 00 0A` | `00 01 00 00 00 03 01 83 07` |
| 19:07:51 | 1 | FC01 Read Coils | 0 / 10 | `00 02 00 00 00 06 01 01 00 00 00 0A` | `00 02 00 00 00 03 01 81 07` |
| ~19:19 | 0 | FC03 | 0 / 10 | — | Timeout |
| 19:20:26 | 255 | FC03 | 0 / 10 | `00 01 00 00 00 06 FF 03 00 00 00 0A` | Timeout |
| 19:20:52 | 1 | FC03 | 1000 / 10 | `00 02 00 00 00 06 01 03 03 E8 00 0A` | `00 02 00 00 00 03 01 83 07` |
| 19:21:21 | 1 | FC04 Read Input Registers | 0 / 10 | `00 03 00 00 00 06 01 04 00 00 00 0A` | `00 03 00 00 00 03 01 84 07` |

- Somente o Unit ID `1` responde; IDs `0` e `255` não geram resposta.
- Todas as leituras com Unit ID `1` retornam exceção Modbus **07 (Negative
  Acknowledge)**, independentemente da função e do endereço. Nenhuma resposta
  trouxe exceção 02 (endereço ilegal) ou dados.

### Inferido

- O DF51 tem a pilha Modbus TCP ativa, mas não há mapeamento Modbus servindo
  dados (blocos MBCF/MBSS ausentes, inativos ou o recurso fora de operação).
  A exceção 07 uniforme indica recusa do serviço, não endereço incorreto.
- Varrer outras faixas de endereço pelo QModMaster tem baixa probabilidade de
  sucesso enquanto essa condição persistir.

### Desconhecido

- Se a configuração atual do DF51 contém blocos Modbus e em que estado está o
  recurso; isso exige leitura (upload) da configuração pelo System302/Syscon.
- O mapeamento de variáveis do processo, caso venha a ser criado.

### Próximo gate

Ler a configuração do DF51 com o System302 7.0.5 (upload no Syscon, sem
download) para verificar o estado do recurso e a existência de blocos Modbus.
Criar ou ativar um mapeamento Modbus é alteração de configuração e depende de
autorização explícita e backup verificado, conforme `AGENTS.md`.

## 2026-11-11 — captura passiva Ethernet do DF51

### Observado

- Foi feita uma captura passiva de cinco minutos na interface Ethernet física,
  sem iniciar o System302, alterar IP ou transmitir pacotes.
- O arquivo `ethernet-20261111-elevated.pcapng` tem SHA-256
  `6ea90e63689468e18a426befad50108bc90055c89ee36e7db46c4eec60b43788` e
  contém 10 quadros UDP, durante 270,055 s.
- Todos os quadros foram emitidos pelo MAC `00:30:5C:01:05:52`, de
  `192.168.164.100:4987` para `255.255.255.255:4987`.
- Os anúncios têm 59 bytes UDP e repetem a cada aproximadamente 30 s. O payload
  contém os marcadores `DF51V3.7.5` e `Monitor 3302`.
- Não foram observados pacotes originados pelo notebook, ARP, TCP, comandos de
  engenharia ou tráfego de processo dentro desta janela de captura.

### Conclusão limitada

- A Ethernet está fisicamente conectada ao DF51 e o endereço observado
  `192.168.164.100` é confirmado para seu anúncio de descoberta.
- UDP/4987 é um canal de anúncio. A captura não identifica um canal de leitura
  ou escrita de engenharia, e não autoriza sondagem ativa.

## 2026-11-10 — triagem REA do caminho de RUN/HOLD

### Observado

- A instalação local contém `FBTools/dfbatch/dfbatch.exe`, SHA-256
  `c526f1e87d6e67fe41dfd3a434851e2211bc108d31f4bdd1531550c2c0d7bee9`.
- O inventário REA classificou o alvo como PE32 x86 nativo, sem diretório CLI;
  portanto ele não é um assembly .NET e requer um provedor nativo para
  decompilação.
- A triagem de bytes do artefato encontrou os rótulos `Run Modes`,
  `Hold Modes` e `mode 1`, além de código Python 2 empacotado relacionado a
  Telnet/FTP. Esses textos identificam o melhor alvo conhecido, mas não
  estabelecem a sintaxe, o transporte ou a semântica segura de um comando.
- O REA 6.7.0 e o Ghidra 12.1.4 foram localizados. A configuração apontava para
  um JDK removido e foi atualizada para o JDK 21 instalado; o provedor nativo,
  porém, ainda expira durante o autoteste Java no host Windows e não produziu
  pseudocódigo.

Evidências REA: `ev_7ff816c4540dd917ef9b8e45a6beb3eff0e4bddfc1da8aaa425d1bc4399cd673`,
`ev_d9739d1d07a3f6b6c450d35ec0c078f34720eb16cedef6af72c3574b38569a42`,
`ev_e7cc8af7e8953d4ecbd334cf0e779939872876c5ac21e50663c7b39877dfbedf`,
`ev_5198bfeb8c11f6565a28d9e3f438c319ad2f42936c0207f9209478069ffaf313`.

### Inferido

- `dfbatch.exe`, e não o anúncio UDP 4987, é o primeiro alvo a decompilar para
  reconstruir o caminho de RUN/HOLD.

### Desconhecido

- Formato exato da solicitação, autenticação, porta, resposta e pré-condições.
- Se o mecanismo se aplica ao firmware DF51 3.7.5 e à configuração da bancada.
- A função do DF51 na planta e a confirmação física, endereço, protocolo e
  modelo do controlador.

### Próximo gate

Reiniciar/reconectar o REA com o JDK corrigido e obter pseudocódigo/evidência de
chamadas para o fluxo `mode`. Não transmitir comandos com base apenas nas
strings empacotadas.

### Continuação REA

- O REA/Ghidra 12.1.4 voltou a operar após a correção do JDK.
- O recurso PE `PYTHONSCRIPT` de `dfbatch.exe` foi identificado em offset
  13.940, com 36.369 bytes e SHA-256
  `32ac0d09c69a2eded262ec00f76016d3b739086504578a617cd5f6e4a2207405`.
- A reconstrução do bytecode Python 2.5 confirmou transporte Telnet/23 com
  autenticação e associou `Run Mode` a `firmware` e `Hold Mode` a `monitor`.
- O prompt aceito pelo cliente não inclui DF51. A presença do DF51 apenas na
  tabela de tipos de hardware não confirma suporte aos comandos, nem que ele
  seja o controlador da planta.
- `DfiDiver.exe`, SHA-256
  `b339f777382ecad1a14975cdf9fd2720425d674f051c5cfd75712c929ac3a2a3`,
  reconhece `DF51*.abs` e escrita de memória, mas a busca REA não encontrou um
  caminho RUN/HOLD nesse utilitário.

Evidências adicionais: `ev_c063b40f079d004a980ffbe570bc0bc966d751a2e4405a634039a7c1f656e14d`,
`ev_618ccaa58939da4fb453b7999060aad0eaf253ad22e05ae10cfafbee732921b4`,
`ev_f188e86218c23dad11829c11b2df57a46f0f49979beddf66c3efce67972673c4`,
`ev_362a8d768f1e0e22fdccf2a23883d4f892e3d6c781a15c4780b240a0c10bf4c4`,
`ev_3474f0fc2c39fba18b7609009dbe29f6dc99f70716e79b8b02b0f9c6e3a8651f`.

## 2026-10-28 — mídia System302 v8.2.2 SP1

### Observado

- A mídia local contém `fscommand/NetConf.cab` (4.941.663 bytes). O arquivo foi
  extraído somente para a área local ignorada pelo Git, sem executar qualquer
  payload.
- O arquivo extraído com SHA-256
  `e79d77cf6f343b82d4f1428d217f22fba1bbc8dc80bbe81cc1a1dc4ed56fe81d`
  é uma DLL PE x86 nativa. Seus metadados de versão declaram:
  - nome original: `DEVNet.dll`;
  - produto: `DEVNet Dynamic Link Library`;
  - empresa: `Hilscher GmbH`;
  - versão: `2.6.9.8`.
- A triagem de strings locais desse mesmo arquivo encontrou os termos
  `Fieldbus`, `OPC`, `HSE`, `Profibus` e `Network`.
- `CheckPreinstall.exe` é um assembly .NET Framework 4.0 x64 de pré-instalação,
  SHA-256 `5305299de3b90fd822469b95477bb2ff0743860805443d6c6b10bad545d2a8c1`.
  A inspeção de metadados não executou nem carregou o assembly.

Evidências REA: `ev_e335d52d1714f8fd1a28533e5382f1d6f6b11cf57ae833cd1e9bd4aa90af90f1`,
`ev_2bdc41cfc16ef965d1343a20a2e138af4db95f3e1e7ac1d67953f329f089818f`.

### Inferido

- O pacote NetConf inclui uma dependência de comunicação industrial da Hilscher;
  isso o torna um alvo prioritário para investigação estática posterior.

### Desconhecido

- O protocolo realmente usado pela bancada, seus endereços, portas, papéis de
  cada endpoint e se a DLL participa da comunicação com a planta.
- A presença de strings não prova que uma função, configuração ou protocolo seja
  utilizado em tempo de execução.

### Próximo gate

Correlacionar esta evidência com uma captura passiva autorizada ou com a
documentação/etiqueta do equipamento antes de criar ou habilitar um adaptador
real. Não foram enviados pacotes, executados instaladores ou alteradas
configurações de rede durante esta investigação.

## 2026-10-28 — captura passiva Ethernet

### Observado

- A captura passiva `ethernet-20261028-154658.pcapng` contém sete quadros em
  aproximadamente 90 segundos, SHA-256
  `811e897a584dfe984c7dda906ba9b81991389e78fc6f8a143183555d1f62f849`.
- Quatro quadros são anúncios UDP, emitidos a cada 30 segundos por
  `192.168.164.100:4987` para `255.255.255.255:4987`, usando o MAC
  `00:30:5C:01:05:52`.
- O payload de cada anúncio contém os marcadores textuais `DF51V3.7.5` e
  `Monitor 3302`.
- Os outros três quadros são requisições ARP do notebook, cujo endereço
  automático na interface Ethernet era `169.254.57.19`; a captura não contém
  resposta ARP do equipamento.
- `EthernetDiscoveryBeaconParser` em `app/` já reconhece os dois marcadores
  acima exclusivamente a partir de um payload fornecido, sem abrir conexão.

### Inferido

- O DFI302 ou um componente diretamente ligado à bancada é a origem provável
  dos anúncios; a associação não foi confirmada por etiqueta ou inventário
  físico.
- A estação não estava configurada na sub-rede anunciada e, por isso, a captura
  não demonstra conectividade IP direta.

### Desconhecido

- O significado completo dos bytes não textuais do datagrama, a máscara e o
  gateway da rede, e se a porta UDP 4987 oferece um protocolo de leitura.
- O vínculo entre o componente Hilscher DeviceNet encontrado na mídia e o
  anúncio UDP observado.

### Próximo gate

Prosseguir com engenharia reversa estática e replay offline do anúncio. Não
configurar IP, abrir sessão com `192.168.164.100` ou habilitar a escuta ao vivo
do aplicativo sem uma decisão explícita para alterar o ambiente de rede.

## 2026-10-28 — estação de engenharia local

### Observado

- System302 v8.2.2 SP1 foi instalado no notebook e o Studio302 abriu com um
  banco de engenharia local vazio.
- A estação foi configurada somente para **Engineering**, sem habilitar
  *Communication Server*, pois o notebook estava fora da rede da planta.

### Desconhecido

- A função do DF51, e a configuração, módulos de E/S e projeto do controlador.

### Limite

- A instalação local não estabeleceu sessão com o DF51, não alterou a
  configuração da planta e não enviou comandos.

## 2026-10-29 — validação em campo do DF51

### Observado

- A captura passiva `ethernet-20261029-100437.pcapng` registrou 232 quadros,
  SHA-256 `08d04cc90b222e4c29b641c5e6d1e0705f2dddab753b2dd9a794b577e95d00eb`.
- O MAC `00:30:5C:01:05:52` anunciou quatro vezes, a cada 30 segundos,
  `192.168.164.100:4987` para broadcast, mantendo os marcadores `DF51V3.7.5`
  e `Monitor 3302`.
- Após uma configuração temporária e reversível do notebook como
  `192.168.164.10/24`, um único ICMP para `192.168.164.100` respondeu em 7 ms.
  A tabela ARP retornou o mesmo MAC observado na captura.
- A consulta HTTP direcionada para `192.168.164.100` expirou; não há webserver
  HTTP acessível na porta 80.
- O IP temporário foi removido e a Ethernet do notebook voltou a DHCP/APIPA
  (`169.254.57.19`) ao fim da visita.

### Confirmado

- O equipamento na rede é um SMAR **DF51**, da plataforma DFI302, com Ethernet
  de 10 Mbps e quatro canais FOUNDATION Fieldbus H1.
- O DF51 é o controlador Ethernet/FOUNDATION Fieldbus e o DF65 é o
  coprocessador lógico, conforme inventário posteriormente informado pelo
  operador. A captura confirma o endereço do DF51, mas não o projeto, o
  mapeamento de E/S nem o protocolo de leitura da aplicação.

### Limites mantidos

- Não foram enviados firmware, projeto, parâmetros, comandos RUN/HOLD, reset
  ou operações de download ao DF51.
- O FBTools Wizard mostrou somente operações de download para o DF51; elas não
  foram executadas por não constituírem recuperação somente de leitura.

## 2026-11-11 — classificação estática do NetConfDownloader

### Observado

- A inspeção estática de `NetConfDownloader.exe` instalado no System302
  (SHA-256 `95ccac48b16190ef7f381c2279d8b189ef9edd2818069f62f196daeab8f98741`)
  identificou os componentes `SmarNetConfOut.cASi` e `SmarNetConfOut.cModbus`.
- As referências expõem `Connect`, `Disconnect` e `Download`; o componente
  Modbus também expõe `WriteChannelGuid`.
- A inspeção não carregou nem executou o binário. Não houve tráfego gerado
  para a planta. Evidência REA:
  `ev_2452d1ffbdb2783d69eb8ad49ebf65df150209501dc2108634f12b87cf63b3d2`.

### Conclusão operacional

O programa é tratado como ferramenta potencialmente alteradora de configuração
AS-i/Modbus e não será usado para descoberta, recuperação do projeto ou RUN do
DF51. A classificação é baseada nos metadados disponíveis; não prova todo o
comportamento do programa.


## 2026-11-11 — busca de backup compatível

### Observado

- A busca restrita por nomes PD3, DF51, DFI302 e System302 nos documentos
  locais não encontrou projeto ou backup identificável da PD3-302.
- A instalação do System302 contém apenas os exemplos de fábrica
  `DF51_SE.ffp` (10.283 bytes) e `DF51_HSE.ffp` (10.482 bytes), ambos com data
  de 2006. Eles não são evidência da configuração da bancada.

### Próximo gate

Obter um backup identificado ou orientação técnica da SMAR para DF51 `V3.7.5`.
O rascunho de solicitação está em `docs/pedido-suporte-smar.md` e não foi
enviado.
