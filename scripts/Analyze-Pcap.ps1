[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$CapturePath,

    [string]$OutputPath
)

$ErrorActionPreference = 'Stop'
$capture = (Resolve-Path -LiteralPath $CapturePath).Path

if (-not $OutputPath) {
    $OutputPath = Join-Path (Split-Path -Parent $capture) 'network-summary.json'
}

$tshark = Get-Command tshark -ErrorAction SilentlyContinue
if (-not $tshark) {
    throw 'TShark não foi encontrado. Instale o Wireshark/TShark antes de analisar uma captura; não use descoberta ativa como substituto.'
}

$protocols = & $tshark.Source -r $capture -q -z io,phs 2>&1
$endpoints = & $tshark.Source -r $capture -q -z endpoints,ip 2>&1
$conversations = & $tshark.Source -r $capture -q -z conv,ip 2>&1

[PSCustomObject]@{
    capture = Split-Path -Leaf $capture
    sha256 = (Get-FileHash -LiteralPath $capture -Algorithm SHA256).Hash.ToLowerInvariant()
    generated_utc = [DateTime]::UtcNow.ToString('o')
    protocol_hierarchy = @($protocols)
    ip_endpoints = @($endpoints)
    ip_conversations = @($conversations)
} | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $OutputPath -Encoding utf8

Write-Host "Resumo salvo em: $OutputPath"
