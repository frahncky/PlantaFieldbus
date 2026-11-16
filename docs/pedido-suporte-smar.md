# Rascunho de solicitação ao suporte SMAR

**Destinatário sugerido:** `techsupport@smar.com.br`  
**Assunto:** PD3-302 / DF51 SN# 1362, firmware V3.7.5 (2003) — compatibilidade com System302 8.2.2.1

Olá, equipe SMAR,

Estamos recuperando uma planta didática PD3-302 FOUNDATION Fieldbus que ficou
inativa por longo período. A estação original usava System302 7.0.5; hoje
dispomos de um notebook com System302 8.2.2.1 (8.2.2 SP1). Precisamos de
orientação para restabelecer a comunicação de engenharia com o DF51 com o menor
risco possível para a configuração existente.

Evidências reunidas:

- Rack informado: DF50, DF65, DF20, DF18, DF19, DF28, DF58, DF51, DF52 e DF53.
- DF51 identificado pelo DFI Diver como `Model DF51 - SN# 1362`, firmware
  `DF51V3.7.5`, datado de 17/10/2003, 3.761.154 bytes. LED RUN aceso.
  DF65 em HOLD.
- Rede: DF51 em `192.168.164.100`, MAC `00:30:5C:01:05:52`; estação em
  `192.168.164.101/24` (mesmo IP da estação original) e `192.168.164.20/24`.
  O DF51 responde a ping e envia anúncio UDP `4987` a cada 30 s com
  `DF51V3.7.5` e `Monitor 3302`.
- Syscon 8.2.2.1, área **HSE**: a Live List mostra somente a própria estação.
  Em captura, a estação envia *FMS Information Report Request* para
  `239.0.0.2:28000` e o DF51 não responde.
- Syscon 8.2.2.1, área **SE** com `Smar.DFIOLEServer.0` e bridge DF51
  (Device Rev 07): "Communication initialization failure".
- Modbus TCP 502 aberto; Unit ID 1 responde exceção 7 a todas as leituras.
- A instalação 8.2.2.1 contém `DF51V3.9.5.ABS`, `DF51V3.9.5R.ABS`,
  `DF51VCF3.9.5.ABS`, `DF51VCF3.9.5R.ABS` e `DF51FBViewEth008.ABS`.
- Não há projeto/backup da planta; apenas os exemplos `DF51_SE.ffp` e
  `DF51_HSE.ffp`.

Poderiam informar:

1. Se o System302 8.2.2.1 suporta DF51 com firmware V3.7.5 e, se sim, qual o
   procedimento (HSE ou SE) para comunicar.
2. Se a atualização para V3.9.5 é o caminho recomendado; qual dos arquivos
   acima corresponde a este DF51 (sem redundância); e o que significa `VCF`.
3. Se a atualização de firmware apaga a configuração/estratégia atualmente
   carregada no DF51, e se há como salvá-la antes (upload) com o 8.2 ou com
   alguma ferramenta.
4. Se é possível obter o System302 7.0.5 (ou a versão compatível com V3.7.5)
   para uso com esta bancada, e quais licenças seriam necessárias.
5. O significado de `Monitor 3302` no anúncio Ethernet do DF51.

Até recebermos essa orientação, não executaremos download, gravação de
firmware, RUN/HOLD, reset ou mudança de parâmetro.

Atenciosamente,

[nome / instituição / contato]

---

Este arquivo é um rascunho local e não foi enviado a ninguém. Anexo sugerido:
`wireshark_EthernetUJ9ZY3.pcapng` (captura de 2026-11-16, não versionada).
