# Perfil provisório — PD3-302 Fieldbus

## Contexto do produto

A [PD3-302 da SMAR](https://www.smar.com.br/pt/produto/pd3-302-planta-didatica-foundation-fieldbus)
é uma planta didática compacta para demonstrar malhas de controle com
FOUNDATION™ Fieldbus. A supervisão e operação são feitas por uma estação PC com
software, e a estrutura permite configurar malhas sem mudanças mecânicas.
Essas características descrevem a linha de produto; não substituem o projeto,
os parâmetros ou a topologia efetivamente instalados nesta bancada.

## Base observada

- A bancada é uma PD3-302 didática industrial conectada por Ethernet.
- O equipamento observado é um SMAR **DF51** da plataforma DFI302, com uma
  porta Ethernet 10 Mbps e quatro canais FOUNDATION Fieldbus H1. Ele não é o
  PLC da planta. O manual de referência da PD3-F descreve uma CPU DF63, mas o
  modelo instalado nesta bancada, a função do DF51 e o endereço/protocolo do
  controlador ainda devem ser confirmados por etiqueta e projeto.
- O DF51 anuncia `192.168.164.100:4987` em broadcast, com MAC
  `00:30:5C:01:05:52`, firmware `3.7.5` e `Monitor 3302`.
- A conectividade IP foi confirmada uma vez a partir de uma estação temporária
  em `192.168.164.10/24`; o notebook foi restaurado para DHCP depois do teste.
- O formato do anúncio UDP foi decodificado apenas para identidade. O protocolo
  de leitura de processo, os módulos de E/S e a estratégia continuam
  desconhecidos.

## Hipótese visual usada no aplicativo

O aplicativo usa um perfil visual preliminar **FOUNDATION Fieldbus**, marcado
como "dados simulados". Ele apresenta uma malha hidráulica com tags
genéricas de instrumentação (`LI-101`, `FIT-101`, `PT-101`, `TIT-101`), bomba
e válvula de controle. Isso não representa a configuração instalada nem
autoriza comunicação com qualquer equipamento.

## Confirmação necessária

1. Inventário dos módulos de E/S e bornes do rack.
2. Confirmação física do controlador e recuperação de seu projeto/backup ou
   procedimento oficial de leitura aplicável.
3. Revisão humana antes de habilitar qualquer adaptador de leitura.
