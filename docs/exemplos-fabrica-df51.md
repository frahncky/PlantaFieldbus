# Exemplos de fábrica DF51 usados somente offline

Os arquivos instalados com o System302 foram inspecionados estaticamente e são
usados como referência para documentação, simulação e testes offline. Eles não
devem ser importados, comparados online, baixados ou usados para alterar a
PD3-302.

| Exemplo | SHA-256 | Topologia adicional |
| --- | --- | --- |
| \`DF51_SE.ffp\` | \`7384beb88959422ed8b025451c6cb85e4bc61b12eea171583e6b83c4657431e4\` | Uma rede \`Fieldbus1\` e bridge \`DFI302\` |
| \`DF51_HSE.ffp\` | \`90265d0327f0ee79db6bd8f9564e9d935329beaee27be825f9f69e73dd948f8d\` | \`Fieldbus1\`, \`HSE Network\`, host \`HSE_HOST\` e bridge \`DFI302\` |

## Estratégia de controle comum

Os dois projetos trazem uma estratégia chamada \`Cascade\`:

\`\`\`text
TT302 / Temperature-AI → Temperature-PID
                              ↓ CAS_IN
LD302 / Flow-AI        → Flow-PID → Flow Valve-AO / FP302
\`\`\`

O PID de temperatura fornece a referência para o PID de vazão; o PID de vazão
atua sobre a válvula. Há também *Resource Blocks*, blocos transdutores,
agendas de execução e agenda de tráfego FOUNDATION Fieldbus.

## Uso permitido neste repositório

1. Comparar nomes de blocos, ligações e tipos de equipamentos com evidência
   posterior da bancada.
2. Derivar dados de demonstração para o aplicativo, marcados como simulados.
3. Construir testes de replay e documentação do processo de cascata.

## Uso proibido até recuperação validada

- Abrir os exemplos conectados ao DF51.
- Fazer *download*, *upload*, comparação online, firmware, RUN/HOLD ou escrita
  de parâmetros.
- Assumir que TT302, LD302, FP302, tags ou escalas existem na PD3-302 real.

Os exemplos são material didático de referência; não são backup, cópia ou
modelo confirmado da planta instalada.
