# Inventário informado — rack DFI302 da PD3-302

> Fonte: inventário fornecido pelo operador em 10 de novembro de 2026. Validar
> visualmente os códigos e a posição no rack antes de manutenção, configuração
> ou operação.

| Módulo | Função |
| --- | --- |
| DF50 | Fonte de alimentação do backplane, 90–264 Vca |
| DF65 | Coprocessador lógico |
| DF0 | Módulo cego para posições não utilizadas |
| DF20 | Módulo com 8 chaves liga/desliga |
| DF18 | 16 entradas digitais de 120 Vca |
| DF19 | 16 entradas digitais de 240 Vca |
| DF28 | 16 saídas digitais a relé normalmente aberto |
| DF58 | Interface de comunicação RS-232/RS-485 |
| DF51 | Controlador com Ethernet 10 Mbps e 4 canais FOUNDATION Fieldbus H1 |
| DF52 | Fonte de alimentação para redes Fieldbus |
| DF53 | Módulo de impedância para redes Fieldbus |

## Leitura da arquitetura

O DF51 é a cabeça de controle e comunicação Fieldbus; o DF65 fornece a função
lógica. Os módulos DF18, DF19 e DF28 fazem a interface discreta com o painel e
atuadores. DF52 e DF53 energizam e condicionam os segmentos FOUNDATION
Fieldbus. A presença dos módulos não revela, por si só, o mapeamento de sinais,
o projeto carregado ou quais saídas estão ativas.
