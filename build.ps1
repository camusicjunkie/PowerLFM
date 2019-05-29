[cmdletbinding()]
param(
    [string[]]$Task = 'default'
)

Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null

if (-not (Get-Module -Name Pester -ListAvailable)) {Install-Module -Name Pester -Scope CurrentUser -Force}
if (-not (Get-Module -Name psake -ListAvailable)) {Install-Module -Name psake -Scope CurrentUser -Force}
if (-not (Get-Module -Name PSDeploy -ListAvailable)) {Install-Module -Name PSDeploy -Scope CurrentUser -Force}
if (-not (Get-Module -Name PSScriptAnalyzer -ListAvailable)) {Install-Module -Name PSScriptAnalyzer -Scope CurrentUser -Force}

if ($env:APPVEYOR) {
    Write-Output 'Inside APPVEYOR if statement'
    $script:LFMConfig = [pscustomobject] @{
        $APIKey = $env:LFMAPIKey
        $SessionKey = $env:LFMSessionKey
    }
}

Invoke-Psake -buildFile "$PSScriptRoot\psake.ps1" -taskList $Task -Verbose:$VerbosePreference
exit ([int] (-not $psake.build_success))
