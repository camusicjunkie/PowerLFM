function Resolve-Dependency {
    [CmdletBinding()]
    param(
        [switch] $Force
    )

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
        Write-verbose "Bootstrapping PSDepend"

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
    if ($PSBoundParameters.ContainsKey('Force')) { $ipParams.Add('Force', $true)}
    Invoke-PSDepend @ipParams
    Write-Verbose "Project bootstrapped. Returning to Invoke-Build"
}
