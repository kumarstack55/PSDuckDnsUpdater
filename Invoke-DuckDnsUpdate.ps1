 [CmdletBinding()]
param(
    [Parameter(Mandatory)]$Domain,
    [Parameter(Mandatory)]$Token,
    [ValidateSet("IPv4", "IPv6", "Both", "")]
    [string]$Update = ""

)

$scriptPath = Join-Path $PSScriptRoot "Update-DuckDnsDomain.ps1"
. $scriptPath

Update-DuckDnsDomain -Domain $Domain -Token $Token -Update $Update