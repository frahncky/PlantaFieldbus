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
- O controlador é um SMAR **DF51** da plataforma DFI302, com uma porta Ethernet
  10 Mbps e quatro canais FOUNDATION Fieldbus H1. O controle lógico é fornecido
  pelo coprocessador **DF65**; o inventário foi informado pelo operador e deve
  ser conferido nas etiquetas do rack antes de qualquer intervenção.
- O DF51 anuncia `192.168.164.100:4987` em broadcast, com MAC
  `00:30:5C:01:05:52`, firmware `3.7.5` e `Monitor 3302`.
- A conectividade IP foi confirmada uma vez a partir de uma estação temporária
  em `192.168.164.10/24`; o notebook foi restaurado para DHCP depois do teste.
- O formato do anúncio UDP foi decodificado apenas para identidade. O protocolo
  de leitura de processo e a estratégia continuam desconhecidos.

## Hipótese visual usada no aplicativo

O aplicativo usa um perfil visual preliminar **FOUNDATION Fieldbus**, marcado
como "dados simulados". Ele apresenta uma malha hidráulica com tags
genéricas de instrumentação (`LI-101`, `FIT-101`, `PT-101`, `TIT-101`), bomba
e válvula de controle. Isso não representa a configuração instalada nem
autoriza comunicação com qualquer equipamento.

## Confirmação necessária

1. Conferência física do inventário e dos bornes do rack.
2. Recuperação do projeto/backup do DF51/DF65 ou de
   procedimento oficial de leitura aplicável.
3. Revisão humana antes de habilitar qualquer adaptador de leitura.
