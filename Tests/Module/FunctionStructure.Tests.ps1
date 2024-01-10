Describe 'Public function interface checks' -Tag Module {

    BeforeDiscovery {
        # The module will need to be imported during Discovery since we're using it to generate test cases / Context blocks
        $moduleName = 'PowerLFM'
        $projectRoot = Resolve-Path "$PSScriptRoot\..\.."
        $moduleManifestPath = "$projectRoot\$moduleName\$moduleName.psd1"

        Remove-Module -Name $moduleName -Force -ErrorAction SilentlyContinue
        Import-Module $moduleManifestPath -Force

        $module = Get-Module $moduleName

        $commands = @(
            $module.ExportedFunctions.Keys
            $module.ExportedCmdlets.Keys
        ) | ForEach-Object { Get-Command -Name $_ }
    }

    Context "[<_.Name>] interface validation" -ForEach $commands {

        BeforeDiscovery {
            $command = $_

            $mocks = Get-Content -Path $PSScriptRoot\..\..\config\interface.json | ConvertFrom-Json
            $interface = $mocks.($command.Name).Interface
        }

        BeforeAll {
            $command = $_

            $mocks = Get-Content -Path $PSScriptRoot\..\..\config\interface.json | ConvertFrom-Json
            $interface = $mocks.($command.Name).Interface
        }

        It 'CmdletBinding should be declared' {
            $command.CmdletBinding | Should -Be($interface.CmdletBinding)
        }

        It "Should have [$($interface.DefaultParameterSet)] configured as default parameter set" -Skip:(-not $command.DefaultParameterSet) {
            $command.DefaultParameterSet | Should -Be ($interface.DefaultParameterSet)
        }

        It 'Should contain an output type' -Skip:(-not $command.OutputType.Name) {
            $command.OutputType.Name | Should -Be $($interface.OutputType)
        }

        Context 'ParameterSetName [<_.Name>]' -ForEach $command.ParameterSets {

            BeforeDiscovery {
                $parameterSet = $_
                $builtInParameters = ([Management.Automation.PSCmdlet]::CommonParameters +
                                      [Management.Automation.PSCmdlet]::OptionalCommonParameters)

                $parameters = $parameterSet.Parameters | Where-Object Name -notin $builtInParameters
            }

            BeforeAll {
                $parameterSet = $_
                $set = $interface.ParameterSet | Where-Object { $_.Name -eq $parameterSet.Name }
            }

            It 'Should have a parameter set of <_>' -ForEach $parameterSet.Name {
                $_ | Should -Be $set.Name
            }

            Context 'Parameter [<_.Name>] attribute validation' -Foreach $parameters {

                BeforeDiscovery {
                    $parameter = $_
                }

                BeforeAll {
                    $parameter = $_
                    $assertion = $set.Parameters | Where-Object Name -eq $parameter.Name
                }

                It 'Should not be null or empty' {
                    $parameter | Should -Not -BeNullOrEmpty
                }

                It 'Should be of type <_.ParameterType>' -Foreach $parameter {
                    $parameter.ParameterType.Name | Should -Be ($assertion.ParameterType)
                }

                It 'Mandatory should be set to <_.IsMandatory>' -Foreach $parameter {
                    $parameter.IsMandatory | Should -Be($assertion.Mandatory)
                }

                It 'ValueFromPipeline should be set to <_.ValueFromPipeline>' -Foreach $parameter {
                    $parameter.ValueFromPipeline | Should -Be($assertion.ValueFromPipeline)
                }

                It 'ValueFromPipelineByPropertyName should be set to <_.ValueFromPipelineByPropertyName>' -Foreach $parameter {
                    $parameter.ValueFromPipelineByPropertyName | Should -Be($assertion.ValueFromPipelineByPropertyName)
                }

                It 'ValueFromRemainingArguments should be set to <_.ValueFromRemainingArguments>' -Foreach $parameter {
                    $parameter.ValueFromRemainingArguments | Should -Be($assertion.ValueFromRemainingArguments)
                }

                It 'Should have a position of <_.Position>' -Foreach $parameter {
                    $parameter.Position | Should -Be $assertion.Position
                }
            }
        }
    }
}
