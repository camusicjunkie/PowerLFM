[cmdletbinding()]
param(
    [string[]]$Task = 'default'
)

$null = Get-PackageProvider -Name NuGet -ForceBootstrap

if (-not (Get-Module -Name Pester -ListAvailable)) {Install-Module -Name Pester -Scope CurrentUser -Force}
if (-not (Get-Module -Name psake -ListAvailable)) {Install-Module -Name psake -Scope CurrentUser -Force}
if (-not (Get-Module -Name PSDeploy -ListAvailable)) {Install-Module -Name PSDeploy -Scope CurrentUser -Force}
if (-not (Get-Module -Name PSScriptAnalyzer -ListAvailable)) {Install-Module -Name PSScriptAnalyzer -Scope CurrentUser -Force}

Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\PowerLFM\PowerLFM.psd1

Get-ChildItem Env:\ALLUSERSPROFILE
if ($env:APPVEYOR) {
    Write-Output 'Inside APPVEYOR if statement'
    #$acParams = @{
    #    APIKey = $env:LFMAPIKey
    #    SessionKey = $env:LFMSessionKey
    #    SharedSecret = $env:LFMSharedSecret
    #}
    $acParams = @{
        APIKey = 'APIKey'
        SessionKey = 'SessionKey'
        SharedSecret = 'SharedSecret'
    }
    Add-LFMConfiguration @acParams

    Get-LFMConfiguration
}
else {
    Get-LFMConfiguration
}

Invoke-Psake -buildFile "$PSScriptRoot\psake.ps1" -taskList $Task -Verbose:$VerbosePreference
exit ([int] (-not $psake.build_success))
