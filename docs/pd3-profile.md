# Perfil provisório — SMAR PD3

## Base observada

- A bancada foi identificada pelo operador como SMAR PD3.
- A série possui variantes PD3-301 (HART), PD3-302 (FOUNDATION Fieldbus) e
  PD3-303 (PROFIBUS). A identificação exata da variante instalada permanece
  pendente.
- O manual da série orienta conectar a estação de trabalho por Ethernet ao
  controlador disponível na planta ou ao switch.

## Hipótese visual usada no aplicativo

O aplicativo usa um perfil demonstrativo **PD3-302 / FOUNDATION Fieldbus**,
marcado como "em validação". Ele apresenta uma malha hidráulica com tags
genéricas de instrumentação (`LI-101`, `FIT-101`, `PT-101`, `TIT-101`), bomba
e válvula de controle. Isso não representa a configuração instalada nem
autoriza comunicação com qualquer equipamento.

## Confirmação necessária

1. Foto da etiqueta/modelo da planta e do controlador/gateway.
2. Captura passiva no cabo Ethernet.
3. Revisão humana da topologia e do adaptador correspondente.

## Fontes públicas

- https://www.smar.com.br/pt/categoria/plantas-didaticas
- https://www.smar.com.br/pt/produto/pd3-302-planta-didatica-foundation-fieldbus
