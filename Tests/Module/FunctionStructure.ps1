Describe 'Public function interface checks' -Tag Module {

    #region Discovery

    # The module will need to be imported during Discovery since we're using it to generate test cases / Context blocks
    $moduleName = 'PowerLFM'
    $projectRoot = Resolve-Path "$PSScriptRoot\..\.."
    $moduleManifestPath = "$projectRoot\$moduleName\$moduleName.psd1"

    Import-Module $moduleManifestPath

    $shouldProcessParameters = 'WhatIf', 'Confirm'

    # Generate command list for generating Context / TestCases
    $module = Get-Module $moduleName
    $commands = @(
        $module.ExportedFunctions.Keys
        $module.ExportedCmdlets.Keys
    )

    #endregion Discovery

    foreach ($command in $commands) {

        Context "[$command] interface validation" {

            #region Discovery

            $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
            $contextMock = $mocks.'Get-LFMAlbumInfo'.AlbumInfo

            $cmd = Get-Command -Name $command
            $testCases = @{ Cmd = $cmd}

            #endregion Discovery

            It 'CmdletBinding should be declared' -TestCases $testCases {
                $Cmd.CmdletBinding | Should -BeTrue
            }

            It 'Should have album set as default parameter set' -TestCases $testCases -Skip:(-not $cmd.DefaultParameterSet) {
                $Cmd.DefaultParameterSet | Should -Be 'album'
            }

            It "Should contain an output type" -TestCases $testCases -Skip:(-not $cmd.OutputType.Name) {
                $Cmd.OutputType.Name | Should -Be 'PowerLFM.Album.Info'
            }

            foreach ($parameterSet in $cmd.ParameterSets.Name) {

                Context "ParameterSetName $parameterSet" {

                    It "Should have a parameter set of $parameterSet" -TestCases $testCases {
                        $Cmd.ParameterSets.Name | Should -Contain 'album'
                    }

                    foreach ($parameter in $parameterSet.Parameters) {

                        It 'Should not be null or empty' {
                            $parameter | Should -Not -BeNullOrEmpty
                        }

                        It 'Should be of type System.String' {
                            $parameter.ParameterType.ToString() | Should -Be System.String
                        }

                        It 'Mandatory should be set to True' {
                            $parameter.IsMandatory | Should -BeTrue
                        }

                        It 'ValueFromPipeline should be set to False' {
                            $parameter.ValueFromPipeline | Should -BeFalse
                        }

                        It 'ValueFromPipelineByPropertyName should be set to True' {
                            $parameter.ValueFromPipelineByPropertyName | Should -BeTrue
                        }

                        It 'ValueFromRemainingArguments should be set to False' {
                            $parameter.ValueFromRemainingArguments | Should -BeFalse
                        }

                        It 'Should have a position of 0' {
                            $parameter.Position | Should -Be 0
                        }
                    }
                }
            }
        }
    }
}
