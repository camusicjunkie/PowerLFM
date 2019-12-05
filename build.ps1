[CmdletBinding()]
param(
    [parameter(Position=0)]
    $Task = 'Default'
)

$modules = @(
    'BuildHelpers',
    'InvokeBuild',
    'Pester',
    'platyPS',
    'PSScriptAnalyzer'
)

'Starting build...'
'Installing module dependencies...'

Get-PackageProvider -Name 'NuGet' -ForceBootstrap | Out-Null

Install-Module -Name $modules -Force -SkipPublisherCheck

Set-BuildEnvironment
Get-ChildItem Env:BH*
Get-ChildItem Env:APPVEYOR*

$Error.Clear()

"Invoking build action [$Task]"

Invoke-Build -Task $Task -Result 'Result'
if ($Result.Error)
{
    $Error[-1].ScriptStackTrace | Out-String
    exit 1
}

exit 0
