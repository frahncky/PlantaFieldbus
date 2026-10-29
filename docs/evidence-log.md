# Registro de evidências

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

- A configuração do controlador, seus módulos de E/S e qualquer projeto
  existente no DFI302.

### Limite

- A instalação local não estabeleceu sessão com o controlador, não alterou a
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

- O equipamento na rede é um controlador SMAR **DF51**, da plataforma DFI302,
  com Ethernet de 10 Mbps e quatro canais FOUNDATION Fieldbus H1.

### Limites mantidos

- Não foram enviados firmware, projeto, parâmetros, comandos RUN/HOLD, reset
  ou operações de download ao DF51.
- O FBTools Wizard mostrou somente operações de download para o DF51; elas não
  foram executadas por não constituírem recuperação somente de leitura.
