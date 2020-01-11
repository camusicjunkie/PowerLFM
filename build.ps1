[CmdletBinding()]
param(
    [ValidateSet('Build', 'Test', 'Deploy')]
    [string] $Task,

    # Install all modules and packages in *.depend.psd1
    [switch] $ResolveDependency
)

Import-Module "$PSScriptRoot\BuildTools.psm1" -Force

if ($ResolveDependency) {
    Write-Host "Resolving Dependencies... [this can take a moment]"

    $rsParams = @{}
    if ($PSBoundParameters.ContainsKey('Verbose')) { $rsParams.Add('Verbose', $Verbose) }
    Resolve-Dependency @rsParams
}

$Error.Clear()

Invoke-Build -Task $Task -Result 'Result'

if ($Result.Error)
{
    $Error[-1].ScriptStackTrace | Out-String
    exit 1
}

exit 0
