[CmdletBinding()]
param(
    [ValidateSet('start', 'stop')]
    [string]$Action = 'start',

    [string]$OutputDirectory = (Join-Path $PSScriptRoot '..\\field-capture')
)

$ErrorActionPreference = 'Stop'
$OutputDirectory = [IO.Path]::GetFullPath($OutputDirectory)

if (-not (Test-Path -LiteralPath $OutputDirectory)) {
    New-Item -ItemType Directory -Path $OutputDirectory | Out-Null
}

$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'

if ($Action -eq 'start') {
    Get-NetAdapter | Select-Object Name, InterfaceDescription, Status, MacAddress, LinkSpeed |
        ConvertTo-Json | Set-Content -LiteralPath (Join-Path $OutputDirectory "adapters-$timestamp.json") -Encoding utf8
    Get-NetIPAddress | Select-Object InterfaceAlias, AddressFamily, IPAddress, PrefixLength |
        ConvertTo-Json | Set-Content -LiteralPath (Join-Path $OutputDirectory "addresses-$timestamp.json") -Encoding utf8

    # Passive capture only. No discovery packets or PLC commands are sent.
    pktmon stop 2>$null
    pktmon start --etw -p 0
    Write-Host 'Captura passiva iniciada. Aguarde tráfego normal e execute o modo stop.'
    exit 0
}

pktmon stop
$etl = Join-Path $OutputDirectory "fieldbus-$timestamp.etl"
$pcapng = Join-Path $OutputDirectory "fieldbus-$timestamp.pcapng"
Move-Item -LiteralPath "$env:windir\System32\LogFiles\PktMon\PktMon.etl" -Destination $etl -Force
pktmon etl2pcap $etl --out $pcapng
Write-Host "Captura salva em: $pcapng"
