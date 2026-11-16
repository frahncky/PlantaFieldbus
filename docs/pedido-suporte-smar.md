# Rascunho de solicitação ao suporte SMAR

**Destinatário sugerido:** `techsupport@smar.com.br`  
**Assunto:** PD3-302 / DF51 V3.7.5 (SE) + DF65 em HOLD — leitura de parâmetros e recuperação do projeto

Olá, equipe SMAR,

Estamos recuperando uma planta didática PD3-302 FOUNDATION Fieldbus que ficou
inativa por longo período. O computador original (System302 7.0.5) ainda não
foi localizado. Precisamos de orientação para ler a configuração e os valores
de processo **sem escrever** no controlador e para entender como recuperar o
DF65 com segurança.

## Situação levantada (16/11/2026)

- Rack informado: DF50, DF65, DF20, DF18, DF19, DF28, DF58, DF51, DF52 e DF53.
- Estado físico: **DF51 em RUN** e **DF65 em HOLD**.
- DF51 firmware `V3.7.5`, MAC `00:30:5C:01:05:52`, IP `192.168.164.100`;
  o anúncio UDP/4987 contém `DF51V3.7.5` e `Monitor 3302`.
- Estação disponível: System302 **8.2.2 SP1**.
- O DF51 opera em modo **SE**: não aparece na Live List HSE, mas é encontrado
  pelo `Smar.DFIOLEServer.0`. Um *upload* somente leitura (topologia, lista de
  equipamentos e de blocos) retornou:
  - controlador `DFI-PD3`, 4 canais H1; equipamentos apenas no canal 1:
    `LIT-31`, `FY-31`, `FIT-31`, `FIT-32`, `FY-32`, `TIT-31`, `TIT-32`;
  - blocos no DF51: `RES1`, `TRD-1362`, `DIAG-1`, `MBCF1`, `MBCM1`, `MBCM2`.
- `FIT-31` (LD302, ID `0003020001:SMAR-LD302:000810463`) e `TIT-31` (TT302,
  ID `0003020002:SMAR-TT302:004808101`) aparecem na rede, mas **não
  comissionados** e sem blocos.
- Na caracterização on-line (ex.: `LIT-31_AI1`, `DFI-PD3_MBCM1`) a lista de
  parâmetros aparece, mas **nenhum valor é retornado**. O upload registrou
  `Block creation failure during upload` (FB VFD).
- `Export → Consolidate OPC Database` falha com
  `Write access denied to user MicrosoftAccount\<usuário>`, mesmo com o
  Studio302 executado como administrador, login de segurança do System302
  desativado e permissão de modificação em `C:\Program Files (x86)\Smar`.
- O LogicView do 8.2.2 mostra a opção **DF65 Logic desabilitada**.
- `Smar.DF65Server.1` (df65svr2, build 8051006) inicia, mas o TagView
  retorna `Error connecting to OPC server`.
- Um mestre Modbus TCP externo recebe exceção 07 do DF51 em todas as
  leituras, coerente com o DF51 ser apenas mestre (MBCM).

## Perguntas

1. Qual versão do System302 e qual *device support* são compatíveis com o
   DF51 `V3.7.5` em modo SE para ler valores on-line dos blocos? Como obter o
   pacote para importar no 8.2.2 (File → Import Device Support)?
2. O que causa `Write access denied to user ...` no Consolidate OPC Database e
   como conceder esse direito (usuário do Configuration Workspace, pasta,
   serviço)?
3. Como habilitar **DF65 Logic** no LogicView 8.2.2 (licença ou componente)?
4. Qual o procedimento recomendado para diagnosticar o DF65 em HOLD e, se o
   programa estiver íntegro, retorná-lo a RUN **sem download**? Como saber se
   o programa ladder foi perdido (bateria/NVRAM)?
5. Como configurar o `Smar.DF65Server.1` para leitura (rota via DF51 ou
   serial) sem alterar o DF65?
6. Há algum cuidado ao comissionar `FIT-31` e `TIT-31` para não afetar a
   estratégia em execução?
7. Quais informações adicionais (fotos, etiquetas, números de série, logs,
   arquivo `.ffp`) devemos enviar?

Até recebermos orientação, não executaremos download, firmware, RUN/HOLD,
reset, comissionamento ou mudança de parâmetro.

Atenciosamente,

[nome / instituição / contato]

---

Este arquivo é um rascunho local e não foi enviado a ninguém.
