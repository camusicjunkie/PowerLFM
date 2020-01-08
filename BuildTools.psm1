function Resolve-Dependency {
    [CmdletBinding()]
    param()

    if (-not (Get-PackageProvider -Name NuGet -ForceBootstrap)) {
        $ippParams = @{
            Name = 'Nuget'
            Force = $true
            ForceBootstrap = $true
        }
        if($PSBoundParameters.ContainsKey('Verbose')) { $ippParams.Add('Verbose', $Verbose)}
        $null = Install-PackageProvider @ippParams
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    }

    if (-not (Get-Module -ListAvailable PSDepend)) {
        Write-verbose "BootStrapping PSDepend"
        Write-verbose "Parameter $BuildOutput"

        $imParams = @{
            Name = 'PSDepend'
            AllowClobber = $true
            Confirm = $false
            Force = $true
            Scope = 'CurrentUser'
        }
        if ($PSBoundParameters.ContainsKey('Verbose')) { $imParams.Add('Verbose', $Verbose)}
        Install-Module @imParams
    }

    $ipParams = @{
        Tags = 'Build'
        Confirm = $false
    }
    if ($PSBoundParameters.ContainsKey('Verbose')) { $ipParams.Add('Verbose', $Verbose)}
    Invoke-PSDepend @ipParams
    Write-Verbose "Project bootstrapped. Returning to Invoke-Build"
}

function Get-ModuleInterfaceMap {
    param (
        [string]
        $Path
    )

    $module = Import-Module -Name $Path -PassThru -Force
    $exportedCommands = @(
        $module.ExportedFunctions.Values
        $module.ExportedCmdlets.Values
        $module.ExportedAliases.Values
    )

    foreach ($command in $exportedCommands) {
        foreach ($parameter in $command.Parameters.Keys) {
            if ($false -eq $command.Parameters[$parameter].IsDynamic) {
                '{0}:{1}' -f $command.Name, $command.Parameters[$parameter].Name
                foreach ($alias in $command.Parameters[$parameter].Aliases) {
                    '{0}:{1}' -f $command.Name, $alias
                }
            }
        }
    }
}
