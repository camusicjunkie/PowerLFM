[cmdletbinding()]
param(
    [string[]]$Task = 'default'
)

$null = Get-PackageProvider -Name NuGet -ForceBootstrap

$script:Modules = @(
    'Pester',
    'PSScriptAnalyzer',
    'Psake'
    'PSDeploy'
)

'Starting build...'
'Installing module dependencies...'

Install-Module -Name $script:Modules -Force -SkipPublisherCheck

if ($env:APPVEYOR) {
    Remove-Module -Name PowerLFM -ErrorAction Ignore
    Import-Module -Name $PSScriptRoot\PowerLFM\PowerLFM.psd1

    $acParams = @{
        APIKey = $env:LFMAPIKey
        SessionKey = $env:LFMSessionKey
        SharedSecret = $env:LFMSharedSecret
    }
    Add-LFMConfiguration @acParams
}

Invoke-Psake -buildFile "$PSScriptRoot\psake.ps1" -taskList $Task -Verbose:$VerbosePreference
exit ([int] (-not $psake.build_success))
