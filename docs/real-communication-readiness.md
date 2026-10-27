# Preparação para comunicação real — etapa 4

## Situação
Ainda não foi comprovado qual controlador, gateway, protocolo, endereço ou topologia está instalado. **Nenhuma conexão real deve ser iniciada nesta etapa.**

## Pré-requisitos verificáveis
1. Registrar fotos das etiquetas do controlador, interface, gateway e instrumentos (sem credenciais).
2. Fazer captura **passiva** em laboratório autorizado, sem varredura ou transmissão de pacotes pelo projeto.
3. Gerar manifesto de evidências e resumo de rede pelos scripts existentes; manter PCAP e material restrito fora do GitHub público.
4. Correlacionar documentação do equipamento com tráfego observado; separar fatos, hipóteses e desconhecidos.
5. Validar o tipo exato de interface: OPC DA, OPC UA, Modbus TCP, FOUNDATION Fieldbus HSE ou ponte específica. Não confundir um segmento H1 com Ethernet/IP.
6. Revisar endpoints e mapeamento de tags com responsável técnico; definir qualidade, perda de conexão, intervalo de leitura e logs.
7. Implementar adaptador específico de **leitura apenas** com replay offline, testes, timeouts e desconexão.
8. Autorizar ensaio de leitura em bancada isolada; apenas então rever bloqueio explícito no código. Escrita permanece fora do escopo.

## Código incluído
- `app/lib/domain/real_connection_profile.dart`: catálogo de protocolos candidatos, referências de evidências, validação de prontidão para revisão humana e gate de ativação que **sempre bloqueia** conexão real.
- `app/test/real_connection_profile_test.dart`: testes das condições de bloqueio, sem rede.

## Limites
O perfil de conexão é descritivo e não contém senha, chave nem comando de rede. A checagem de pré-requisitos não constitui autorização automática. Os adaptadores já existentes continuam inativos, sem mudança na interface, simulação ou firmware.
