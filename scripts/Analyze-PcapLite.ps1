[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$CapturePath,

    [string]$OutputPath
)

$ErrorActionPreference = 'Stop'
$capture = (Resolve-Path -LiteralPath $CapturePath).Path
if (-not $OutputPath) {
    $OutputPath = Join-Path (Split-Path -Parent $capture) 'network-summary-lite.json'
}

$bytes = [IO.File]::ReadAllBytes($capture)
if ($bytes.Length -lt 28) { throw 'Arquivo PCAPNG muito pequeno.' }

function Read-U16([byte[]]$data, [int]$offset) {
    return [BitConverter]::ToUInt16($data, $offset)
}

function Read-U32([byte[]]$data, [int]$offset) {
    return [BitConverter]::ToUInt32($data, $offset)
}

function IPv4([byte[]]$data, [int]$offset) {
    return "$($data[$offset]).$($data[$offset + 1]).$($data[$offset + 2]).$($data[$offset + 3])"
}

function MacAddress([byte[]]$data, [int]$offset) {
    return ($data[$offset..($offset + 5)] | ForEach-Object { $_.ToString('X2') }) -join ':'
}

$interfaces = @{}
$etherTypes = @{}
$endpoints = @{}
$macEndpoints = @{}
$packets = 0
$offset = 0

while ($offset + 12 -le $bytes.Length) {
    $blockType = Read-U32 $bytes $offset
    $blockLength = Read-U32 $bytes ($offset + 4)
    if ($blockLength -lt 12 -or $offset + $blockLength -gt $bytes.Length) { break }

    if ($blockType -eq 1 -and $blockLength -ge 20) {
        $id = $interfaces.Count
        $interfaces[$id] = [ordered]@{
            link_type = Read-U16 $bytes ($offset + 8)
            packet_count = 0
        }
    }

    if ($blockType -eq 6 -and $blockLength -ge 32) {
        $interfaceId = Read-U32 $bytes ($offset + 8)
        $capturedLength = Read-U32 $bytes ($offset + 20)
        $packetOffset = $offset + 28
        if ($packetOffset + $capturedLength -le $offset + $blockLength - 4) {
            $packets++
            $interfaceKey = [int]$interfaceId
            if ($interfaces.ContainsKey($interfaceKey)) { $interfaces[$interfaceKey].packet_count++ }
            if ($capturedLength -ge 14) {
                foreach ($mac in @((MacAddress $bytes $packetOffset), (MacAddress $bytes ($packetOffset + 6)))) {
                    if (-not $macEndpoints.ContainsKey($mac)) { $macEndpoints[$mac] = 0 }
                    $macEndpoints[$mac]++
                }
                $etherType = '{0:X4}' -f (([int]$bytes[$packetOffset + 12] -shl 8) -bor $bytes[$packetOffset + 13])
                if (-not $etherTypes.ContainsKey($etherType)) { $etherTypes[$etherType] = 0 }
                $etherTypes[$etherType]++

                $ipOffset = $packetOffset + 14
                if ($etherType -eq '0800' -and $capturedLength -ge 34) {
                    $ihl = ($bytes[$ipOffset] -band 0x0F) * 4
                    if ($ihl -ge 20 -and $capturedLength -ge 14 + $ihl) {
                        foreach ($address in @((IPv4 $bytes ($ipOffset + 12)), (IPv4 $bytes ($ipOffset + 16)))) {
                            if (-not $endpoints.ContainsKey($address)) { $endpoints[$address] = 0 }
                            $endpoints[$address]++
                        }
                    }
                }
            }
        }
    }
    $offset += $blockLength
}

[ordered]@{
    capture = Split-Path -Leaf $capture
    sha256 = (Get-FileHash -LiteralPath $capture -Algorithm SHA256).Hash.ToLowerInvariant()
    parser = 'built-in PCAPNG metadata parser; no application payload decoding'
    packet_count = $packets
    interfaces = @($interfaces.GetEnumerator() | Sort-Object Name | ForEach-Object { [ordered]@{ id = [int]$_.Key; link_type = $_.Value.link_type; packet_count = $_.Value.packet_count } })
    ether_types = @($etherTypes.GetEnumerator() | Sort-Object Name | ForEach-Object { [ordered]@{ type = $_.Key; packet_count = $_.Value } })
    mac_endpoints = @($macEndpoints.GetEnumerator() | Sort-Object Name | ForEach-Object { [ordered]@{ address = $_.Key; packet_count = $_.Value } })
    ipv4_endpoints = @($endpoints.GetEnumerator() | Sort-Object Name | ForEach-Object { [ordered]@{ address = $_.Key; packet_count = $_.Value } })
} | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $OutputPath -Encoding utf8

Write-Host "Resumo leve salvo em: $OutputPath"
