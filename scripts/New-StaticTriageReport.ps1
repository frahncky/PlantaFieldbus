[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$TargetsPath,

    [string]$OutputPath = (Join-Path (Split-Path -Parent $TargetsPath) 'static-triage.md'),

    [ValidateRange(1, 200)]
    [int]$QueueSize = 20
)

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $TargetsPath -PathType Leaf)) {
    throw "Lista de alvos nao encontrada: $TargetsPath"
}

$targets = Get-Content -LiteralPath $TargetsPath -Raw | ConvertFrom-Json
$items = @($targets.candidates | ForEach-Object {
    $module = ($_.relative_path -split '\\')[0]
    $keywords = @($_.keyword_hits | ForEach-Object { [string]$_ })
    [PSCustomObject]@{
        Module = $module
        Path = [string]$_.relative_path
        Bytes = [int64]$_.bytes
        Sha256 = [string]$_.sha256
        Keywords = $keywords
        Score = $keywords.Count
    }
})

$ranked = @($items | Sort-Object @{ Expression = 'Score'; Descending = $true }, @{ Expression = 'Bytes'; Descending = $true }, Path)
$queue = @($ranked | Select-Object -First $QueueSize)
$moduleSummary = @($items | Group-Object Module | ForEach-Object {
    [PSCustomObject]@{
        Module = $_.Name
        Candidates = $_.Count
        HighestScore = ($_.Group | Measure-Object Score -Maximum).Maximum
    }
} | Sort-Object @{ Expression = 'HighestScore'; Descending = $true }, @{ Expression = 'Candidates'; Descending = $true }, Module)

function Escape-MarkdownCell([string]$Value) {
    return $Value.Replace('|', '\|').Replace("`r", ' ').Replace("`n", ' ')
}

$outputDirectory = Split-Path -Parent $OutputPath
if ($outputDirectory -and -not (Test-Path -LiteralPath $outputDirectory)) {
    New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
}

$lines = [System.Collections.Generic.List[string]]::new()
$lines.Add('# Triagem estática — fila para REA')
$lines.Add('')
$lines.Add("Gerado (UTC): $([DateTime]::UtcNow.ToString('o'))")
$lines.Add(('Fonte: `{0}`' -f $targets.source))
$lines.Add(('Lista de alvos: `{0}`' -f $TargetsPath))
$lines.Add('')
$lines.Add('Este relatório é uma priorização por metadados e strings locais. Não prova comportamento, protocolo, comunicação de rede nem compatibilidade com a planta.')
$lines.Add('')
$lines.Add('## Resumo por módulo')
$lines.Add('')
$lines.Add('| Módulo | Candidatos | Maior pontuação |')
$lines.Add('| --- | ---: | ---: |')
foreach ($row in $moduleSummary) {
    $moduleName = Escape-MarkdownCell $row.Module
    $line = '| {0} | {1} | {2} |' -f $moduleName, $row.Candidates, $row.HighestScore
    $lines.Add($line)
}
$lines.Add('')
$lines.Add("## Fila inicial ($($queue.Count) alvos)")
$lines.Add('')
$lines.Add('| # | Módulo | Arquivo | SHA-256 | Pontuação | Termos locais |')
$lines.Add('| ---: | --- | --- | --- | ---: | --- |')
$index = 0
foreach ($row in $queue) {
    $index++
    $terms = $row.Keywords -join ', '
    $moduleName = Escape-MarkdownCell $row.Module
    $path = Escape-MarkdownCell $row.Path
    $escapedTerms = Escape-MarkdownCell $terms
    $line = '| {0} | {1} | {2} | {3} | {4} | {5} |' -f $index, $moduleName, $path, $row.Sha256, $row.Score, $escapedTerms
    $lines.Add($line)
}
$lines.Add('')
$lines.Add('## Próximo passo permitido')
$lines.Add('')
$lines.Add('Com o REA disponível, abrir somente o primeiro alvo ainda não analisado, salvar o identificador da evidência e então avançar conforme uma pergunta técnica específica. Não executar o binário, não configurar rede e não contatar a planta.')

Set-Content -LiteralPath $OutputPath -Value $lines -Encoding utf8
Write-Host "Relatório de triagem salvo em: $OutputPath"
