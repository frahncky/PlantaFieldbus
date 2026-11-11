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
