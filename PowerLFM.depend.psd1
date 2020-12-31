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

    'Microsoft.PowerShell.SecretManagement' = @{
        Version = '0.2.1-alpha1'
        Parameters = @{
            AllowPrerelease = $true
        }
    }

    'Newtonsoft.Json' = @{
        DependencyType = 'Nuget'
        Target = 'BuildOutput\downloads'
    }

    'Gitversion.CommandLine' = @{
        DependencyType = 'Nuget'
        Target = 'BuildOutput\downloads'
        Parameters = @{
            Name = 'Gitversion'
        }
    }

    'Newtonsoft.Json_Copy' = @{
        DependencyType = 'FileSystem'
        Source = 'BuildOutput\downloads\Newtonsoft.Json\lib\netstandard2.0\Newtonsoft.Json.dll'
        Target = 'BuildOutput\PowerLFM\lib'
        Tags = 'Copy'
        DependsOn = 'Newtonsoft.Json'
    }
}
