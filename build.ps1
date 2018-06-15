[cmdletbinding()]
param(
    [string[]]$Task = 'default'
)

if (-not (Get-Module -Name Pester -ListAvailable)) { Install-Module -Name Pester -Scope CurrentUser -Force }
if (-not (Get-Module -Name psake -ListAvailable)) { Install-Module -Name psake -Scope CurrentUser -Force}
if (-not (Get-Module -Name PSDeploy -ListAvailable)) { Install-Module -Name PSDeploy -Scope CurrentUser -Force}

Invoke-Psake -buildFile "$PSScriptRoot\psake.ps1" -taskList $Task -Verbose:$VerbosePreference