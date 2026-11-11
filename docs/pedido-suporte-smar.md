# Rascunho de solicitação ao suporte SMAR

**Destinatário sugerido:** `techsupport@smar.com.br`  
**Assunto:** PD3-302 / DF51 V3.7.5 — procedimento de leitura e recuperação sem escrita

Olá, equipe SMAR,

Estamos recuperando uma planta didática PD3-302 FOUNDATION Fieldbus que ficou
inativa por longo período. O computador original não está disponível. Precisamos
de orientação para identificar a configuração instalada e restabelecer uma
comunicação **somente de leitura**, sem download, alteração de firmware, reset
ou mudança de estado do controlador.

Evidências reunidas:

- Rack informado: DF50, DF65, DF20, DF18, DF19, DF28, DF58, DF51, DF52 e DF53.
- Controlador observado passivamente: DF51, firmware `V3.7.5`, MAC
  `00:30:5C:01:05:52`, anúncio UDP `192.168.164.100:4987`.
- O anúncio também contém `Monitor 3302`.
- A estação disponível tem System302 8.2.2 SP1.
- Não foi localizado projeto/backup da planta; apenas exemplos de fábrica
  `DF51_SE.ffp` e `DF51_HSE.ffp`, que não serão carregados na bancada.

Poderiam informar:

1. O procedimento e a versão de System302 compatíveis com DF51 `V3.7.5` para
   identificar o controlador e recuperar/validar o projeto sem escrever nele.
2. Se existe ferramenta, licença, pacote de suporte ou conversão necessária
   para abrir um backup histórico dessa versão.
3. O significado operacional de `Monitor 3302` no anúncio Ethernet do DF51 e
   se UDP/4987 possui apenas descoberta ou algum método documentado de leitura.
4. Quais informações adicionais (fotos de etiqueta, números de série, logs ou
   arquivo de projeto) devem ser enviadas para confirmar compatibilidade.

Até recebermos essa orientação, manteremos o System302 fora de comunicação com
a planta e não executaremos download, firmware, RUN/HOLD, reset ou mudança de
parâmetro.

Atenciosamente,

[nome / instituição / contato]

---

Este arquivo é um rascunho local e não foi enviado a ninguém.
