# Fluxo autônomo de engenharia reversa

Este fluxo define o que pode ser executado automaticamente a partir de evidências locais e onde é obrigatório parar para revisão humana. Ele não faz descoberta ativa, escrita em PLC ou alteração de rede.

| Fase | Entrada | Execução automática | Saída | Gate |
| --- | --- | --- | --- | --- |
| 0. Preservação | instalador, projeto, captura | hash SHA-256 e inventário | `evidence-manifest.json` | nenhum |
| 1. Artefatos | MSI, CAB, EXE, DLL, GSD | classificação e análise estática com REA | mapa de módulos e evidências | nenhum |
| 2. Rede passiva | PCAPNG/ETL | resumo de hosts, portas, multicast e protocolos | `network-summary.json` | nenhum |
| 3. Correlação | fases 1 e 2 | correlacionar APIs, módulos e tráfego observado | hipótese de protocolo | revisão humana |
| 4. Cliente | hipótese aprovada | gerar adaptador somente leitura e testes offline | cliente simulado | revisão humana |
| 5. Validação | ambiente isolado | testes contra replay/PCAP, nunca contra processo | relatório de compatibilidade | revisão humana |
| 6. Escrita | autorização formal e plano de testes | não automática | plano de comissionamento | autorização explícita |

## Regras operacionais

- Evidência original é imutável e não deve ser enviada ao repositório público.
- Resultados sempre registram hash, ferramenta, data e limitação.
- Uma hipótese não equivale a protocolo confirmado; a confirmação exige tráfego observado ou documentação do equipamento.
- O cliente inicial permanece somente leitura. Qualquer operação de escrita exige autorização explícita e laboratório/ambiente isolado.

## Próxima execução

Após a coleta da rede, execute:

```powershell
./scripts/New-EvidenceManifest.ps1 -EvidenceDirectory ./field-capture
./scripts/Analyze-Pcap.ps1 -CapturePath ./field-capture/<arquivo>.pcapng
```

Depois, entregue os arquivos gerados ao agente para a etapa REA de correlação.

Para artefatos de software já extraídos, gere antes a lista priorizada de alvos:

```powershell
./scripts/Select-StaticTargets.ps1 -ArtifactDirectory <diretorio-extraido> -OutputPath ./investigation/static-targets.json
./scripts/New-StaticTriageReport.ps1 -TargetsPath ./investigation/static-targets.json
```

O segundo comando cria uma fila de análise estática baseada somente em metadados e
strings locais. Ela orienta a ordem das consultas REA, mas não confirma a função
nem o protocolo de qualquer módulo.
