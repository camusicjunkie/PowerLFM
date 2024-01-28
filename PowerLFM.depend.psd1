@{
    PSDependOptions = @{
        AddToPath = $True
        Target = 'build\modules'
        Tags = 'Build'
    }

    InvokeBuild = 'latest'
    Pester = 'latest'
    PSScriptAnalyzer = 'latest'
    PlatyPS = 'latest'
    'Microsoft.PowerShell.SecretManagement' = 'latest'
    'Microsoft.PowerShell.SecretStore' = 'latest'
}
