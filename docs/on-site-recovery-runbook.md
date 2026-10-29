# Roteiro de visita — recuperação do DFI302

Este roteiro serve para recuperar evidências da bancada sem escrever no
controlador, sem mudar seu estado e sem assumir configurações desconhecidas.

## Situação conhecida

- Há anúncios UDP de `192.168.164.100:4987` para broadcast, a cada 30 s.
- O anúncio contém `DF51V3.7.5` e `Monitor 3302`.
- O notebook não tinha um endereço na sub-rede do anúncio durante a primeira
  captura; máscara, gateway e configuração do DFI302 continuam desconhecidos.
- O System302 foi instalado e configurado em casa como estação de engenharia
  offline. O *Communication Server* ficou deliberadamente desabilitado.

## Antes de conectar o notebook

1. Confirmar que a planta está parada e que nenhuma pessoa depende das bombas,
   sirene ou comandos do painel durante a inspeção.
2. Fotografar, sem mexer em fiação:
   - etiqueta completa do controlador e de cada módulo do rack;
   - LEDs do controlador (HOLD, RUN, FAIL, FORCE e Ethernet);
   - bornes e identificação dos cabos Ethernet;
   - frente e etiquetas da botoeira/painel.
3. Anotar data, horário e qualquer alteração observada nos LEDs.
4. Conectar o notebook somente ao mesmo segmento Ethernet já usado para a
   captura passiva; não conectar em duas redes industriais ao mesmo tempo.

## Coleta passiva primeiro

1. Registrar a configuração atual do adaptador Ethernet do notebook para que
   possa ser restaurada depois.
2. Fazer uma nova captura passiva de dois minutos.
3. Confirmar se o anúncio `192.168.164.100:4987` ainda aparece, se há outros
   MACs e se existe resposta ARP do controlador.
4. Preservar o arquivo original e registrar o SHA-256 antes de analisá-lo.

## Gate: configurar a interface do notebook

Só avançar se a captura confirmar o mesmo equipamento e houver autorização na
hora. A mudança deve ser **somente no adaptador Ethernet do notebook**,
reversível, e nunca no PLC.

- Não usar endereços de Wi-Fi, VPN ou adaptadores de loopback no System302.
- Não adivinhar máscara, gateway ou um IP livre a partir do endereço
  `192.168.164.100`.
- Registrar os valores antigos antes da mudança e restaurá-los ao fim da
  visita.
- Após definir valores confirmados para a sub-rede, testar apenas resolução
  básica e uma nova captura; não iniciar download, upload, RUN/HOLD, reset ou
  detecção automática ampla.

## System302 no local

1. Abrir **System302 Settings** e habilitar *Communication Server* somente
   depois de selecionar a interface Ethernet correta.
2. Abrir Studio302 e registrar visualmente as informações que ele apresentar
   sobre o controlador.
3. Se houver uma operação de descoberta, leitura, upload, download, alteração
   de IP ou mudança de estado, parar na tela e registrar a opção. Não confirmar
   a operação sem revisão humana do impacto.

## Encerramento

1. Fechar o Studio302 e desabilitar o *Communication Server* se ele não for
   mais necessário.
2. Restaurar a configuração original da Ethernet do notebook.
3. Arquivar capturas, fotos e anotações com data e origem.
4. Atualizar `docs/evidence-log.md`, separando observado, inferido e
   desconhecido.
