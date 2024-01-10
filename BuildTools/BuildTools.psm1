function Resolve-Dependency {
    [CmdletBinding()]
    param()

    if (-not (Get-PackageProvider -Name NuGet -ForceBootstrap)) {
        $ippParams = @{
            Name           = 'Nuget'
            Force          = $true
            ForceBootstrap = $true
        }
        if ($PSBoundParameters.ContainsKey('Verbose')) { $ippParams.Add('Verbose', $Verbose) }
        $null = Install-PackageProvider @ippParams
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    }

    if (-not (Get-Module -ListAvailable PSDepend)) {
        Write-Verbose "Bootstrapping PSDepend"

        $imParams = @{
            Name         = 'PSDepend'
            AllowClobber = $true
            Confirm      = $false
            Force        = $true
            Scope        = 'CurrentUser'
        }
        if ($PSBoundParameters.ContainsKey('Verbose')) { $imParams.Add('Verbose', $Verbose) }
        Install-Module @imParams
    }

    $ipParams = @{
        Tags  = 'Build'
        Force = $true
    }
    if ($PSBoundParameters.ContainsKey('Verbose')) { $ipParams.Add('Verbose', $Verbose) }
    Invoke-PSDepend @ipParams
    Write-Verbose "Project bootstrapped. Returning to Invoke-Build"
}

function ConvertTo-JsonFromCommand {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline)]
        [System.Management.Automation.CommandInfo[]]
        $Command
    )

    $builtInParameters = ([Management.Automation.PSCmdlet]::CommonParameters +
                          [Management.Automation.PSCmdlet]::OptionalCommonParameters)

    $interface = foreach ($cmd in $Command) {
        $parameterSets = foreach ($parameterSet in $cmd.ParameterSets) {
            $parameters = $parameterSet.Parameters.Where({ $_.Name -notin $builtInParameters })

            [pscustomobject] @{
                Name = $parameterSet.Name
                Parameters = foreach ($parameter in $parameters) {
                    [pscustomobject] @{
                        'Name' = $parameter.Name
                        'ParameterType' = $parameter.ParameterType.Name
                        'Mandatory' = $parameter.IsMandatory
                        'ValueFromPipeline' = $parameter.ValueFromPipeline
                        'ValueFromPipelineByPropertyName' = $parameter.ValueFromPipelineByPropertyName
                        'ValueFromRemainingArguments' = $parameter.ValueFromRemainingArguments
                        'Position' = $parameter.Position
                    }
                }
            }
        }

        [pscustomobject] @{
            $cmd.Name = @{
                'Interface' = [pscustomobject] @{
                    'CmdletBinding' = $cmd.CmdletBinding
                    'DefaultParameterSet' = $cmd.DefaultParameterSet
                    'OutputType' = $cmd.OutputType.Name
                    'ParameterSet' = $parameterSets
                }
            }
        }
    }

    $interface | ConvertTo-Json -Depth 7
}

<#PSScriptInfo
.VERSION 1.0.2
.AUTHOR Roman Kuzmin
.COPYRIGHT (c) Roman Kuzmin
.GUID 78b68f80-80c5-4cc1-9ded-e2ae165a9cbd
.TAGS Invoke-Build, TabExpansion2, Register-ArgumentCompleter
.LICENSEURI http://www.apache.org/licenses/LICENSE-2.0
.PROJECTURI https://github.com/nightroman/Invoke-Build
#>

<#
.Synopsis
	Argument completers for Invoke-Build parameters.

.Description
	The script registers Invoke-Build completers for parameters Task and File.

	Completers can be used with:

	* PowerShell v5 native Register-ArgumentCompleter
	Simply invoke Invoke-Build.ArgumentCompleters.ps1, e.g. in a profile.

	* TabExpansionPlusPlus https://github.com/lzybkr/TabExpansionPlusPlus
	Put Invoke-Build.ArgumentCompleters.ps1 to the TabExpansionPlusPlus module
	directory in order to be loaded automatically. Or invoke it after importing
	the module, e.g. in a profile.

	* TabExpansion2.ps1 https://www.powershellgallery.com/packages/TabExpansion2
	Put Invoke-Build.ArgumentCompleters.ps1 to the path in order to be loaded
	automatically on the first completion. Or invoke after TabExpansion2.ps1,
	e.g. in a profile.
#>

Register-ArgumentCompleter -CommandName Invoke-Build.ps1 -ParameterName Task -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $boundParameters)

    (Invoke-Build -Task ?? -File ($boundParameters['File'])).Keys -like "$wordToComplete*" | . { process {
        New-Object System.Management.Automation.CompletionResult $_, $_, 'ParameterValue', $_
    } }
}

Register-ArgumentCompleter -CommandName Invoke-Build.ps1 -ParameterName File -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $boundParameters)

    Get-ChildItem -Directory -Name "$wordToComplete*" | . { process {
        New-Object System.Management.Automation.CompletionResult $_, $_, 'ProviderContainer', $_
    } }

    if (!($boundParameters['Task'] -eq '**')) {
        Get-ChildItem -File -Name "$wordToComplete*.ps1" | . { process {
            New-Object System.Management.Automation.CompletionResult $_, $_, 'Command', $_
        } }
    }
}
