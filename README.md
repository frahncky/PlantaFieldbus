# PlantaFieldbus

Base aberta para investigar e construir uma integração independente com uma planta didática.

## Estado atual

A arquitetura exata da planta ainda precisa ser confirmada por observação passiva da rede Ethernet.

## Próximo passo

Consulte [docs/captura-passiva.md](docs/captura-passiva.md) e execute o script de coleta quando o notebook estiver conectado à rede da planta. O resultado será usado para identificar protocolos, portas e multicast observados antes de implementar qualquer cliente.

O processo completo, seus artefatos e seus gates estão em [docs/automation-plan.md](docs/automation-plan.md).

## Aplicação de operação

O protótipo desktop fica em [`app/`](app/). Ele inicia em simulação local e
não executa descoberta de rede, não se conecta a PLC e não permite escrita.
Consulte a [sequência de desenvolvimento](docs/software-roadmap.md) para as
etapas de interface, simulador e adaptadores.

Os perfis dos agentes e a máquina de estados estão em [agents/](agents/).

## Limites

Este repositório não contém instaladores, binários, chaves de licença, projetos de terceiros ou dados de processo. Nenhuma ferramenta aqui faz descoberta ativa, escreve no PLC ou altera a configuração da planta.

