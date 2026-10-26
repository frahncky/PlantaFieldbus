# Captura passiva

Use este procedimento somente em uma rede que você esteja autorizado a observar.

1. Conecte o notebook à mesma rede Ethernet da estação/controlador, sem alterar IP, máscara ou gateway.
2. Abra PowerShell **como administrador** na raiz deste repositório. O PktMon
   precisa de privilégios elevados; se o script informar acesso negado, não
   houve captura ativa.
3. Execute `./scripts/Start-FieldbusCapture.ps1 -Action start`.
4. Espere de dois a cinco minutos com a planta em operação normal. Não abra o SYSTEM302 e não envie comandos.
5. Execute `./scripts/Start-FieldbusCapture.ps1 -Action stop`.
   Se a captura já tiver sido parada e faltar apenas converter o ETL, execute
   `./scripts/Start-FieldbusCapture.ps1 -Action convert`.
6. Preserve os arquivos PCAPNG e JSON produzidos. Não publique capturas em repositórios públicos.

O script apenas registra a configuração local e captura tráfego já existente; não envia sondagens, não altera interfaces e não escreve no PLC.

