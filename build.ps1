[cmdletbinding()]
param(
    [string[]]$Task = 'default'
)

$null = Get-PackageProvider -Name NuGet -ForceBootstrap

$Script:Modules = @(
    'Pester',
    'PSScriptAnalyzer',
    'Psake'
    'PSDeploy'
)

'Starting build...'
'Installing module dependencies...'

Install-Module -Name $Script:Modules -Force

Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\PowerLFM\PowerLFM.psd1

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
