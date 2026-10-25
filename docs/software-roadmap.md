# Sequência automática — novo software

## Entregue agora

1. Aplicação Flutter para Windows em `app/`.
2. Painel operacional em modo de simulação local.
3. Sinótico inicial, leituras simuladas e navegação para topologia, histórico e conexão.
4. Escrita em PLC bloqueada por projeto.

## Próximas etapas automáticas permitidas

1. Separar simulador, modelos de tags e histórico em uma camada de domínio.
2. Persistir histórico e eventos simulados localmente.
3. Criar interfaces somente leitura para `Simulation`, `OPC`, `Modbus TCP` e `SMAR/HSE`.
4. Implementar testes com replay para os adaptadores; os reais permanecem inativos até haver evidência de protocolo.
5. Importar a topologia observada da captura passiva.

## Gates obrigatórios

- Sem instalação ou execução do software legado.
- Sem descoberta ativa, varredura ou alteração de rede.
- Sem conexão com PLC antes da identificação do adaptador.
- Sem escrita sem autorização explícita e laboratório.
