[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$EvidenceDirectory,

    [string]$OutputPath = (Join-Path $EvidenceDirectory 'evidence-manifest.json')
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $EvidenceDirectory).Path
$outputDirectory = Split-Path -Parent $OutputPath
if ($outputDirectory -and -not (Test-Path -LiteralPath $outputDirectory)) {
    New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
}

$items = Get-ChildItem -LiteralPath $root -File -Recurse |
    Where-Object { $_.Name -notmatch '^(?:.*\.(?:key|pem|pfx|lic)|evidence-manifest\.json)$' } |
    ForEach-Object {
        [PSCustomObject]@{
            relative_path = $_.FullName.Substring($root.Length).TrimStart('\')
            bytes = $_.Length
            modified_utc = $_.LastWriteTimeUtc.ToString('o')
            sha256 = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
        }
    }

[PSCustomObject]@{
    generated_utc = [DateTime]::UtcNow.ToString('o')
    root = $root
    files = @($items)
} | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath $OutputPath -Encoding utf8

Write-Host "Manifesto salvo em: $OutputPath"
