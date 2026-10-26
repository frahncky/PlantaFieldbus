[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [int]$InterfaceNumber,

    [ValidateRange(1, 3600)]
    [int]$DurationSeconds = 180,

    [string]$OutputDirectory = ''
)

$ErrorActionPreference = 'Stop'

$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]::new($identity)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    throw 'Abra o PowerShell como Administrador antes de iniciar a captura passiva com TShark/Npcap.'
}

if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    $scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
    $OutputDirectory = Join-Path $scriptDirectory '..\field-capture'
}

$tshark = 'C:\Program Files\Wireshark\tshark.exe'
if (-not (Test-Path -LiteralPath $tshark)) {
    throw 'TShark não foi encontrado em C:\Program Files\Wireshark\tshark.exe.'
}

$OutputDirectory = [IO.Path]::GetFullPath($OutputDirectory)
New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
$capture = Join-Path $OutputDirectory ("ethernet-{0}.pcapng" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))

# TShark listens only. It does not send discovery packets or PLC commands.
& $tshark -i $InterfaceNumber -a ("duration:{0}" -f $DurationSeconds) -w $capture
if ($LASTEXITCODE -ne 0) {
    throw "TShark terminou com código $LASTEXITCODE."
}

Write-Host "Captura passiva salva em: $capture"
