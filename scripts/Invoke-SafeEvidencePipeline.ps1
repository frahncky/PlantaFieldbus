[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$EvidenceDirectory,

    [string]$ArtifactDirectory = '',

    [string]$OutputDirectory = '',

    [int64]$MaximumCaptureBytes = 5MB
)

$ErrorActionPreference = 'Stop'
$evidence = (Resolve-Path -LiteralPath $EvidenceDirectory).Path
if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    $OutputDirectory = Join-Path $evidence 'analysis'
}
New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null

$results = [System.Collections.Generic.List[object]]::new()
function Invoke-Phase([string]$Name, [scriptblock]$Action) {
    try {
        & $Action
        $results.Add([pscustomobject]@{ phase = $Name; status = 'completed'; message = '' })
    }
    catch {
        $results.Add([pscustomobject]@{ phase = $Name; status = 'failed'; message = $_.Exception.Message })
    }
}

Invoke-Phase 'preservation' {
    & (Join-Path $PSScriptRoot 'New-EvidenceManifest.ps1') `
        -EvidenceDirectory $evidence `
        -OutputPath (Join-Path $OutputDirectory 'evidence-manifest.json')
}

$allCaptures = @(Get-ChildItem -LiteralPath $evidence -File -Recurse |
    Where-Object { $_.Extension -in '.pcap', '.pcapng' })
$captures = @($allCaptures | Where-Object { $_.Length -le $MaximumCaptureBytes })
foreach ($capture in @($allCaptures | Where-Object { $_.Length -gt $MaximumCaptureBytes })) {
    $results.Add([pscustomobject]@{
        phase = "pcap:$($capture.Name)"
        status = 'skipped'
        message = "Arquivo com $($capture.Length) bytes excede o limite automático de $MaximumCaptureBytes bytes."
    })
}
foreach ($capture in $captures) {
    $baseName = [IO.Path]::GetFileNameWithoutExtension($capture.Name)
    Invoke-Phase "pcap-lite:$($capture.Name)" {
        & (Join-Path $PSScriptRoot 'Analyze-PcapLite.ps1') `
            -CapturePath $capture.FullName `
            -OutputPath (Join-Path $OutputDirectory "$baseName.lite.json")
    }
    Invoke-Phase "pcap-tshark:$($capture.Name)" {
        & (Join-Path $PSScriptRoot 'Analyze-Pcap.ps1') `
            -CapturePath $capture.FullName `
            -OutputPath (Join-Path $OutputDirectory "$baseName.summary.json")
    }
}

if (-not [string]::IsNullOrWhiteSpace($ArtifactDirectory)) {
    Invoke-Phase 'static-triage' {
        $artifacts = (Resolve-Path -LiteralPath $ArtifactDirectory).Path
        $targets = Join-Path $OutputDirectory 'static-targets.json'
        & (Join-Path $PSScriptRoot 'Select-StaticTargets.ps1') `
            -ArtifactDirectory $artifacts -OutputPath $targets
        & (Join-Path $PSScriptRoot 'New-StaticTriageReport.ps1') `
            -TargetsPath $targets -OutputPath (Join-Path $OutputDirectory 'static-triage.md')
    }
}

$report = [pscustomobject]@{
    generated_utc = [DateTime]::UtcNow.ToString('o')
    evidence_directory = $evidence
    output_directory = [IO.Path]::GetFullPath($OutputDirectory)
    captures_processed = $captures.Count
    large_capture_limit_bytes = $MaximumCaptureBytes
    results = @($results)
    next_gate = 'A sessão de leitura autorizada ou a especificação do protocolo é necessária antes de qualquer adaptador real.'
    safety = 'Este fluxo não captura tráfego, não altera rede, não executa o software legado e não envia pacotes.'
}
$report | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $OutputDirectory 'pipeline-report.json') -Encoding utf8
Write-Host "Pipeline concluído. Relatório: $(Join-Path $OutputDirectory 'pipeline-report.json')"
