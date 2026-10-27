[CmdletBinding()]
param(
  [ValidateRange(10, 3600)]
  [int]$DurationSeconds = 120,
  [string]$InterfaceName = 'Ethernet',
  [string]$OutputDirectory = ''
)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
if (-not $OutputDirectory) {
  $OutputDirectory = Join-Path $root 'field-capture'
}
$OutputDirectory = [IO.Path]::GetFullPath($OutputDirectory)
New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null

$tshark = Join-Path $env:ProgramFiles 'Wireshark\tshark.exe'
if (-not (Test-Path -LiteralPath $tshark)) {
  $command = Get-Command tshark -ErrorAction SilentlyContinue
  if (-not $command) {
    throw 'Wireshark/TShark não encontrado. Instale com Npcap.'
  }
  $tshark = $command.Source
}

$adapter = Get-NetAdapter -Name $InterfaceName -ErrorAction Stop
if ($adapter.Status -ne 'Up') {
  throw "A interface '$InterfaceName' não está ativa."
}

$interfaces = @(& $tshark -D)
if ($LASTEXITCODE -ne 0) {
  throw 'Falha ao listar interfaces do TShark.'
}
$selectedInterfaces = @(
  $interfaces | Where-Object {
    if ($_ -match '\(([^()]*)\)$') {
      $Matches[1] -eq $InterfaceName
    } else {
      $false
    }
  }
)
if ($selectedInterfaces.Count -ne 1) {
  Write-Host 'Interfaces do TShark:'
  $interfaces | ForEach-Object { Write-Host $_ }
  throw "Não foi possível selecionar exclusivamente '$InterfaceName'. Informe -InterfaceName com o nome exato."
}

$device = ($selectedInterfaces[0] -split ' ', 2)[0].TrimEnd('.')
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$capture = Join-Path $OutputDirectory "df51-$stamp.pcapng"
$report = Join-Path $OutputDirectory "df51-$stamp-report.txt"

Write-Host "Interface: $InterfaceName | $($adapter.LinkSpeed)"
Write-Host "Captura passiva durante $DurationSeconds segundos. Nenhum comando será enviado ao DF51."
& $tshark -i $device -a "duration:$DurationSeconds" -w $capture
if ($LASTEXITCODE -ne 0) {
  throw "Captura falhou (código $LASTEXITCODE). Verifique permissão Npcap."
}

$sha = (Get-FileHash -LiteralPath $capture -Algorithm SHA256).Hash
$hierarchy = @(& $tshark -r $capture -q -z io,phs)
$endpoints = @(& $tshark -r $capture -q -z endpoints,ip)
$macs = @(& $tshark -r $capture -q -z endpoints,eth)

@(
  'PlantaFieldbus - diagnóstico PASSIVO SMAR DF51',
  "Gerado em: $(Get-Date -Format o)",
  "Interface: $InterfaceName",
  "Arquivo: $(Split-Path -Leaf $capture)",
  "SHA256: $sha",
  'AVISO: Endereços e nomes de rede podem ser sensíveis. Revise antes de compartilhar.',
  '--- Hierarquia de protocolos ---'
) + $hierarchy + @('--- Endpoints IPv4 ---') + $endpoints +
  @('--- Endpoints Ethernet/MAC ---') + $macs |
  Set-Content -LiteralPath $report -Encoding UTF8

Write-Host "Concluído. Relatório: $report"
Write-Host 'Revise o relatório antes de enviar. PCAP bruto fica apenas no notebook.'
