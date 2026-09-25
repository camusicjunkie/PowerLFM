@{
    PSDependOptions                         = @{
        AddToPath = $True
        Target    = 'build\modules'
        Tags      = 'Build'
    }

    ModuleBuilder                           = 'latest'
    InvokeBuild                             = 'latest'
    Pester                                  = '6.0.0'
    PSScriptAnalyzer                        = 'latest'
    PlatyPS                                 = 'latest'
    'Microsoft.PowerShell.SecretManagement' = 'latest'
    'Microsoft.PowerShell.SecretStore'      = 'latest'
    'newtonsoft.json'                       = 'latest'
}
