 [CmdletBinding()]
param(
    [Parameter(Mandatory)]$Domain,
    [Parameter(Mandatory)]$Token
)

$scriptPath = Join-Path $PSScriptRoot "Update-DuckDnsDomain.ps1"
. $scriptPath

Update-DuckDnsDomain -Domain $Domain -Token $Token