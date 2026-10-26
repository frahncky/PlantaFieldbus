# Perfil da planta didática — SMAR DFI302 DF51

## Identificação declarada pelo operador
- **Controlador:** SMAR DFI302 DF51 (informado pelo responsável pela planta).
- **Identificação física por etiqueta:** ainda pendente de confirmação.
- **Porta física:** Ethernet RJ-45 10 Mbps, conforme especificação do fabricante.
- **Rede de campo:** quatro segmentos FOUNDATION Fieldbus H1 independentes, 31,25 kbit/s.
- **Endereço IP, firmware, configuração e dispositivos H1:** desconhecidos; não presumir defaults de manuais.

## Proposta de integração
**Via preferencial a investigar:** servidor OPC clássico (OPC DA / DFI OLE Server) da SMAR instalado e licenciado em computador Windows com SYSTEM302, acessado por ponte local somente leitura. A existência operacional do servidor na bancada ainda **não foi confirmada**.

**Alternativa:** cliente compatível com serviços de comunicação expostos efetivamente pelo DF51, somente após documentação, evidência passiva e revisão técnica. O RJ-45 10 Mbps não comprova por si só OPC UA, Modbus TCP nem cliente HSE genérico.

Arquitetura proposta:
PlantaFieldbus (UI) → serviço Windows (somente leitura) → servidor OPC DA SMAR existente → Ethernet → SMAR DF51 → instrumentos H1.

## Portas de decisão
1. Confirmar foto de etiqueta da CPU DF51 e versão de firmware.
2. Identificar PC de engenharia/supervisão: SYSTEM302 instalado? servidor DFI OLE Server disponível e funcional?
3. Documentar endereço e rota Ethernet apenas com inventário autorizado e captura passiva, sem scan.
4. Obter lista de tags/nós autorizados do servidor com tipos, unidades, status e intervalos de leitura.
5. Validar cliente OPC DA offline e depois em bancada isolada; nenhuma escrita ou troca de setpoint.

## Fontes primárias
- SMAR, DFI302 User Manual: https://www.smar.com.br/public/img/produtos/arquivos/dfi302me.pdf
- SMAR, DFI302 manual português: https://www.smarnet.com.br/litnet/Manuaispdf/DFI302MP.pdf

## Bloqueios
As classes OPC/Modbus/HSE do aplicativo permanecem sem comunicação real. A identificação do modelo **não** autoriza ativação automática ou envio de comandos.
