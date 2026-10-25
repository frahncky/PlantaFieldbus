[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$ArtifactDirectory,

    [string]$OutputPath = (Join-Path $ArtifactDirectory 'static-targets.json'),

    [int64]$MaximumCandidateBytes = 25MB
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $ArtifactDirectory).Path
$keywords = '(?i)opc|ole|hse|fieldbus|profibus|smar|dfi|df[0-9]{2}|netconf|network|syscon|pc[i]?302'
$outputDirectory = Split-Path -Parent $OutputPath
if ($outputDirectory -and -not (Test-Path -LiteralPath $outputDirectory)) {
    New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
}

$candidates = foreach ($file in Get-ChildItem -LiteralPath $root -File -Recurse) {
    if ($file.Length -gt $MaximumCandidateBytes) { continue }

    $stream = [IO.File]::OpenRead($file.FullName)
    try {
        $first = $stream.ReadByte()
        $second = $stream.ReadByte()
        if ($first -ne 0x4D -or $second -ne 0x5A) { continue }

        $take = [Math]::Min($file.Length, 1MB)
        $buffer = New-Object byte[] $take
        $stream.Position = 0
        [void]$stream.Read($buffer, 0, $take)
    }
    finally {
        $stream.Dispose()
    }

    $ascii = [Text.Encoding]::ASCII.GetString($buffer)
    [string[]]$matches = @([regex]::Matches($ascii, $keywords) | ForEach-Object { $_.Value } | Select-Object -Unique)
    if ($matches.Count -eq 0 -and $file.FullName -notmatch $keywords) { continue }

    [PSCustomObject]@{
        relative_path = $file.FullName.Substring($root.Length).TrimStart('\\')
        bytes = $file.Length
        sha256 = (Get-FileHash -LiteralPath $file.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
        keyword_hits = [string[]]$matches
    }
}

[PSCustomObject]@{
    generated_utc = [DateTime]::UtcNow.ToString('o')
    source = $root
    maximum_candidate_bytes = $MaximumCandidateBytes
    candidates = [object[]]@($candidates | Sort-Object relative_path)
} | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $OutputPath -Encoding utf8

Write-Host "Alvos estáticos salvos em: $OutputPath"
