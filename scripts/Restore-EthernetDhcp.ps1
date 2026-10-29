[CmdletBinding()]
param(
    [string]$InterfaceAlias = 'Ethernet',
    [string]$TemporaryAddress = '192.168.164.10'
)

$ErrorActionPreference = 'Stop'
Set-NetIPInterface -InterfaceAlias $InterfaceAlias -AddressFamily IPv4 -Dhcp Enabled
Remove-NetIPAddress -InterfaceAlias $InterfaceAlias -AddressFamily IPv4 -IPAddress $TemporaryAddress -Confirm:$false -ErrorAction SilentlyContinue
ipconfig /renew $InterfaceAlias
Get-NetIPAddress -InterfaceAlias $InterfaceAlias -AddressFamily IPv4 |
    Select-Object IPAddress, PrefixLength, PrefixOrigin, AddressState
