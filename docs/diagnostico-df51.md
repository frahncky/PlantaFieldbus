# Captura passiva DF51 — um comando

Requisitos: Windows PowerShell, Wireshark com TShark/Npcap instalado, interface Ethernet ligada ao DF51. Execute no PowerShell com permissões adequadas para captura Npcap.

A partir de **qualquer diretório**, use o caminho completo onde clonou o projeto, por exemplo:

```powershell
& "C:\Users\frahn\PlantaFieldbus\scripts\Diagnose-DF51.ps1"
```

Caso seu projeto esteja em outro diretório, ajuste apenas esse caminho.

O programa seleciona a interface Windows chamada `Ethernet`, sem depender do número variável do TShark; registra 120 segundos de tráfego existente; em seguida salva `field-capture/df51-*-report.txt` e `.pcapng` ao lado do repositório. O relatório apresenta protocolos e endpoints (que podem ser sensíveis). **Revise antes de compartilhar. Não compartilhe PCAP bruto publicamente.**

Se o nome da conexão for diferente: `-InterfaceName "Ethernet 2"`. Para ajustar a duração: `-DurationSeconds 180`.

Limites: nenhuma varredura, ping, escrita, configuração IP ou comando ao DF51. Rede sem tráfego espontâneo pode produzir relatório vazio. O resultado não confirma automaticamente HSE, IP do controlador ou protocolo de aplicação. Não habilita comunicação real.
