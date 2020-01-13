@{
    PSDependOptions = @{
        AddToPath = $True
        Target = 'BuildOutput\modules'
        Tags = 'Build'
    }

    BuildHelpers = 'latest'
    InvokeBuild = 'latest'
    Pester = '4.9.0'
    PSScriptAnalyzer = 'latest'
    PlatyPS = 'latest'
    PSDeploy = 'latest'

    'Newtonsoft.Json' = @{
        DependencyType = 'Nuget'
        Target = 'BuildOutput\downloads'
    }

    'Gitversion.CommandLine' = @{
        DependencyType = 'Nuget'
        Target = 'BuildOutput\downloads'
        Parameters = @{
            DLLName = 'Gitversion'
        }
    }

    'Newtonsoft.Json_Copy' = @{
        DependencyType = 'FileSystem'
        Source = 'BuildOutput\downloads\Newtonsoft.Json\lib\netstandard2.0\Newtonsoft.Json.dll'
        Target = 'BuildOutput\PowerLFM\bin'
        Tags = 'Copy'
        DependsOn = 'Newtonsoft.Json'
    }
}
