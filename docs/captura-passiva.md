# Captura passiva

Use este procedimento somente em uma rede que você esteja autorizado a observar.

1. Conecte o notebook à mesma rede Ethernet da estação/controlador, sem alterar IP, máscara ou gateway.
2. Abra PowerShell **como administrador** na raiz deste repositório. O PktMon
   precisa de privilégios elevados; se o script informar acesso negado, não
   houve captura ativa.
3. Execute `./scripts/Test-FieldbusCaptureReadiness.ps1` e preserve o JSON.
   Ele apenas verifica TShark/PktMon, adaptadores e endereços locais.
4. Execute `./scripts/Start-FieldbusCapture.ps1 -Action start`.
5. Espere de dois a cinco minutos com a planta em operação normal. Não abra o SYSTEM302 e não envie comandos.
6. Execute `./scripts/Start-FieldbusCapture.ps1 -Action stop`.
   Se a captura já tiver sido parada e faltar apenas converter o ETL, execute
   `./scripts/Start-FieldbusCapture.ps1 -Action convert`.
7. Execute `./scripts/New-EvidenceManifest.ps1 -EvidenceDirectory ./field-capture`.
8. Preserve os arquivos PCAPNG, JSON e manifesto produzidos. Não publique
   capturas em repositórios públicos.

Depois de voltar para um ambiente de análise, execute:

```powershell
./scripts/Invoke-SafeEvidencePipeline.ps1 -EvidenceDirectory ./field-capture
```

Ele calcula hashes e produz resumos locais do PCAP. Não captura tráfego, não
abre o System302 e não envia pacotes.

O script apenas registra a configuração local e captura tráfego já existente; não envia sondagens, não altera interfaces e não escreve no PLC.

## Captura vinculada a uma interface Ethernet

Quando Wireshark e Npcap estiverem instalados, prefira uma captura vinculada à
interface física: ela evita misturar o tráfego Wi-Fi do notebook na evidência.

1. Abra PowerShell como administrador.
2. Liste interfaces com `& "C:\Program Files\Wireshark\tshark.exe" -D`.
3. Identifique o número que contém `Ethernet` e execute, por exemplo:
   `./scripts/Capture-EthernetPassive.ps1 -InterfaceNumber 4 -DurationSeconds 180`.

O script apenas escuta a interface indicada pelo operador durante o intervalo
escolhido. Não cria conexões, não faz ARP, ping ou descoberta ativa.

## Critério de entrega

Traga de volta a pasta `field-capture` completa, incluindo o PCAPNG e o
`evidence-manifest.json`. A análise começará pela validação do hash e pela
separação de anúncios, ARP e tráfego de engenharia observado; nenhuma hipótese
de protocolo será usada para transmitir pacotes à planta.

