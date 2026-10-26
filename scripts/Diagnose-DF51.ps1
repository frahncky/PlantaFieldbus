[CmdletBinding()]
param(
  [ValidateRange(10,3600)][int]$DurationSeconds = 120,
  [string]$InterfaceName = 'Ethernet',
  [string]$OutputDirectory = ''
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
if (-not $OutputDirectory) { $OutputDirectory = Join-Path $root 'field-capture' }
$OutputDirectory = [IO.Path]::GetFullPath($OutputDirectory)
New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
$tshark = Join-Path $env:ProgramFiles 'Wireshark\tshark.exe'
if (-not (Test-Path -LiteralPath $tshark)) {
  $command = Get-Command tshark -ErrorAction SilentlyContinue
  if (-not $command) { throw 'Wireshark/TShark nao encontrado. Instale com Npcap.' }
  $tshark = $command.Source
}
$adapter = Get-NetAdapter -Name $InterfaceName -ErrorAction Stop
if ($adapter.Status -ne 'Up') { throw "A interface '$InterfaceName' nao esta ativa." }
$interfaces = @(& $tshark -D)
if ($LASTEXITCODE -ne 0) { throw 'Falha ao listar interfaces do TShark.' }
$matches = @($interfaces | Where-Object { $_ -match '\\((.+)\\)$' -and $Matches[1] -eq $InterfaceName })
if ($matches.Count -ne 1) {
  Write-Host 'Interfaces do TShark:'; $interfaces | ForEach-Object { Write-Host $_ }
  throw "Nao foi possivel selecionar exclusivamente '$InterfaceName'. Informe -InterfaceName com o nome exato."
}
$device = ($matches[0] -split ' ',2)[1] -replace ' \\(.*$',''
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$capture = Join-Path $OutputDirectory "df51-$stamp.pcapng"
$report = Join-Path $OutputDirectory "df51-$stamp-report.txt"
Write-Host "Interface: $InterfaceName | $($adapter.LinkSpeed)"
Write-Host "Captura passiva durante $DurationSeconds segundos. Nenhum comando sera enviado ao DF51."
& $tshark -i $device -a "duration:$DurationSeconds" -w $capture
if ($LASTEXITCODE -ne 0) { throw "Captura falhou (codigo $LASTEXITCODE). Verifique permissao Npcap." }
$sha = (Get-FileHash -LiteralPath $capture -Algorithm SHA256).Hash
$hierarchy = @(& $tshark -r $capture -q -z io,phs)
$endpoints = @(& $tshark -r $capture -q -z endpoints,ip)
$macs = @(& $tshark -r $capture -q -z endpoints,eth)
@(
  'PlantaFieldbus - diagnostico PASSIVO SMAR DF51',
  "Gerado em: $(Get-Date -Format o)",
  "Interface: $InterfaceName",
  "Arquivo: $(Split-Path -Leaf $capture)",
  "SHA256: $sha",
  'AVISO: Enderecos e nomes de rede podem ser sensiveis. Revise antes de compartilhar.',
  '--- Hierarquia de protocolos ---'
) + $hierarchy + @('--- Endpoints IPv4 ---') + $endpoints +
  @('--- Endpoints Ethernet/MAC ---') + $macs |
  Set-Content -LiteralPath $report -Encoding UTF8
Write-Host "Concluido. Relatorio: $report"
Write-Host 'Revise o relatorio antes de enviar. PCAP bruto fica apenas no notebook.'
