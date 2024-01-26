@{
    PSDependOptions = @{
        AddToPath = $True
        Target = 'BuildOutput\modules'
        Tags = 'Build'
    }

    BuildHelpers = 'latest'
    InvokeBuild = 'latest'
    Pester = 'latest'
    PSScriptAnalyzer = 'latest'
    PlatyPS = 'latest'
    PSDeploy = 'latest'
    'Microsoft.PowerShell.SecretManagement' = 'latest'
    'Microsoft.PowerShell.SecretStore' = 'latest'

    'Gitversion.CommandLine' = @{
        DependencyType = 'Nuget'
        Target = 'BuildOutput\downloads'
        Parameters = @{
            Name = 'Gitversion'
        }
    }
}
