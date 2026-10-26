[CmdletBinding()]
param(
    [ValidateSet('start', 'stop')]
    [string]$Action = 'start',

    [string]$OutputDirectory = ''
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    $scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
    $OutputDirectory = Join-Path $scriptDirectory '..\\field-capture'
}

$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]::new($identity)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'Abra o PowerShell como Administrador antes de iniciar ou parar a captura passiva com PktMon.'
}

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
    # Do not stop a previous session here: an operator may need to preserve it.
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
