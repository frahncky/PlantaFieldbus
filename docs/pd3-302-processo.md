# Processo padrão da PD3-302 / PD3-F

> Este documento descreve a planta de referência do manual PD3-F da SMAR. A
> configuração instalada deve ser conferida no P&ID, nas etiquetas e no projeto
> da própria bancada antes de qualquer operação.

## Como o processo funciona

A planta opera normalmente em circuito fechado de água. Duas bombas fazem a
circulação entre o tanque de abastecimento, o tanque de aquecimento e o tanque
de mistura. Há duas válvulas de controle de vazão, instrumentos de vazão,
temperatura e nível, e resistências de imersão para aquecer a água.

```text
tanque de abastecimento ── bombas ──> tanque de aquecimento ──> tanque de mistura
          ^                                                        │
          └────────────────────── retorno de água ─────────────────┘
```

## Malhas didáticas de referência

- Temperatura do tanque de aquecimento: realimentação negativa com ação
  antecipativa da vazão; o elemento final são as resistências de imersão.
- Temperatura do tanque de mistura: controle em cascata; a temperatura gera o
  setpoint da malha de vazão da água fria, que atua na válvula correspondente.

O SYSTEM302 configura estratégias e dispositivos; o ProcessView supervisiona
variáveis, alarmes e sinóticos. A documentação oficial afirma que somente
pessoal qualificado deve instalar, operar ou manter a planta.

## O que este repositório confirmou

- Um DF51/DFI302 anuncia-se em `192.168.164.100` no segmento Ethernet.
- Esse DF51 não é o controlador da planta.
- O modelo do controlador, o projeto, o P&ID instalado e a topologia de rede
  ainda não foram confirmados. Portanto esta descrição não autoriza conexões,
  alterações de modo ou comandos.

## Fonte

[Manual PD3-F — Instruções, Operação e Manutenção (SMAR)](https://www.smar.com.br/public/img/produtos/arquivos/piloplfmp.pdf)
