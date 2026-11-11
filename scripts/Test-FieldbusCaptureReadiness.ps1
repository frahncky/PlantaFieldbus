[CmdletBinding()]
param(
    [string]$OutputDirectory = ''
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    $scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
    $OutputDirectory = Join-Path $scriptDirectory '..\field-capture'
}

$OutputDirectory = [IO.Path]::GetFullPath($OutputDirectory)
New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null

$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]::new($identity)
$tshark = 'C:\Program Files\Wireshark\tshark.exe'
$pktmon = Get-Command pktmon.exe -ErrorAction SilentlyContinue

$report = [PSCustomObject]@{
    generated_utc = [DateTime]::UtcNow.ToString('o')
    administrator = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    tshark_path = $tshark
    tshark_available = Test-Path -LiteralPath $tshark
    pktmon_available = $null -ne $pktmon
    adapters = @(
        Get-NetAdapter | Select-Object Name, InterfaceDescription, Status, MacAddress, LinkSpeed, ifIndex
    )
    ipv4 = @(
        Get-NetIPAddress -AddressFamily IPv4 |
            Select-Object InterfaceAlias, IPAddress, PrefixLength, AddressState
    )
}

$path = Join-Path $OutputDirectory ('capture-readiness-{0}.json' -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
$report | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $path -Encoding utf8

Write-Host "Pré-check salvo em: $path"
Write-Host 'Este script apenas lê a configuração local; ele não inicia captura, não altera IP e não envia tráfego.'
