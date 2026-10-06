[CmdletBinding()]
param(
    [ValidateSet('.', 'Build', 'DevBuild', 'Test', 'QuickTest', 'Clean', 'GenerateExternalHelp', 'Publish', 'Noop')]
    [string[]] $Task = '.',

    # Test files or folders for QuickTest
    [string[]] $TestPath,

    # Install all modules and packages in *.depend.psd1
    [switch] $ResolveDependency,

    [string] $NuGetApiKey
)

Import-Module "$PSScriptRoot\BuildTools\BuildTools.psm1" -Force

if ($ResolveDependency) {
    Write-Host "Resolving Dependencies... [this can take a moment]"

    $rsParams = @{ }
    if ($PSBoundParameters.ContainsKey('Verbose')) { $rsParams.Add('Verbose', $Verbose) }
    Resolve-Dependency @rsParams
}

$Error.Clear()

$ibParams = @{
    Task = $Task
    Result = 'Result'
}
if ($PSBoundParameters.ContainsKey('NuGetApiKey')) { $ibParams.Add('NuGetApiKey', $NuGetApiKey) }
if ($PSBoundParameters.ContainsKey('TestPath')) { $ibParams.Add('TestPath', $TestPath) }
Invoke-Build @ibParams

if ($Result.Error)
{
    $Error[-1].ScriptStackTrace | Out-String
    exit 1
}

exit 0
