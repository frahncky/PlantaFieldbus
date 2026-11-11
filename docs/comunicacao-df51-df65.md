# Validação de comunicação — DF51 / DF65

## Situação

O DF51 é o controlador Ethernet/FOUNDATION Fieldbus do rack DFI302 e o DF65 é
o coprocessador lógico, conforme o inventário informado pelo operador. A
captura anterior observou o DF51 em `192.168.164.100`, mas não determinou o
protocolo de engenharia nem o conjunto de parâmetros da aplicação.

## Evidência estática do System302

A análise do `FbusComm.dll` (SHA-256
`70052383e1acab15ce6f35a65bd8976177314cce1bf7e51e1be445c385f6b104`) mostrou
operações distintas para leitura, como `ReadParameterReq`, `ReadObjectReq` e
`LiveListReq`, e para alteração, como `WriteParameterReq`, `WriteObjectReq`,
`WriteNetworkConfReq`, `SetDeviceAddressReq` e `ChangeBootOperationalReq`.

Também foram identificadas mensagens relativas a HSE e VCR. Isso demonstra que
o componente instalado tem capacidade de configurar e alterar equipamentos; não
identifica por si só a porta, formato de pacote, credenciais ou parâmetros da
bancada.

Evidências REA: `ev_30b763dca7d11f5788385dc3fcd0d433e28cb019634c25c42bae9db9657bc6cf`,
`ev_4e60c53da02dc516b281bad45e678e8ba91a85701edfe3e96fa5960f7e5de533`,
`ev_c6f97b124e23bc46c36ee6cd47a526df176ca909dedcdd58fb7656014ae5e6f9`.

## Critério para comunicação correta

Comunicação só é considerada correta quando todos os itens abaixo forem
confirmados no local por procedimento oficial:

1. O notebook está no segmento físico correto, com IP, máscara e interface
   confirmados para o DF51.
2. O DF51, DF65 e módulos de E/S foram conferidos visualmente contra o rack.
3. A estação de engenharia usa o projeto/backup correspondente à versão de
   firmware instalada.
4. Uma operação somente de leitura foi executada pelo fluxo oficial e o
   resultado foi conferido com o inventário físico, sem alarmes ou alterações.
5. O mapeamento de E/S, intertravamentos e estado das saídas foi revisado antes
   de qualquer função de escrita ou troca de modo.

## Limites

Esta investigação não enviou pacotes, não iniciou o Communication Server e não
executou o System302 contra a planta. Portanto, ela não garante comunicação com
o DF51: fornece evidência para evitar o uso do caminho de escrita durante a
validação inicial.
