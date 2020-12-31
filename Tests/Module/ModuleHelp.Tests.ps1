Describe 'Public function help checks' -Tag Module {

    BeforeDiscovery {
        # The module will need to be imported during Discovery since we're using it to generate test cases / Context blocks
        $moduleName = 'PowerLFM'
        $projectRoot = Resolve-Path "$PSScriptRoot\..\.."
        $moduleManifestPath = "$projectRoot\$moduleName\$moduleName.psd1"

        Remove-Module -Name $moduleName -Force -ErrorAction SilentlyContinue
        Import-Module $moduleManifestPath

        $shouldProcessParameters = 'WhatIf', 'Confirm'

        $module = Get-Module $moduleName
        $commands = @(
            $module.ExportedFunctions.Keys
            $module.ExportedCmdlets.Keys
        )
    }

    Context "[<_>] help content validation" -ForEach $commands {

        BeforeDiscovery {
            $command = $_

            $fullHelp = Get-Help -Name $command -Full -ErrorAction Ignore

            $parameters = $fullHelp.Parameters.Parameter |
                Where-Object { $_.Name -and $_.Name -notin $shouldProcessParameters } |
                ForEach-Object { @{ Name = $_.Name; Description = $_.Description.Text } }

            $astParameters = @{
                # Ast will be $null if the command is a compiled cmdlet
                Ast        = (Get-Content -Path "function:/$command" -ErrorAction Ignore).Ast
                Parameters = $parameters
            }
        }

        It 'Should have help content' -ForEach $fullHelp {
            param ($Help = $_)
            $Help | Should -Not -BeNullOrEmpty
        }

        It 'Should contain a synopsis' -ForEach $fullHelp {
            param ($Help = $_)
            $Help.Synopsis | Should -Not -BeNullOrEmpty
        }

        It 'Should contain a description' -ForEach $fullHelp {
            param ($Help = $_)
            $Help.Description | Should -Not -BeNullOrEmpty
        }

        It 'Should have at least one usage example' -ForEach $fullHelp {
            param ($Help = $_)
            $Help.Examples.Example.Code.Count | Should -BeGreaterOrEqual 1
        }

        # This will be skipped for compiled commands ($ast.Ast will be $null)
        It 'Should have a help entry for all parameters' -ForEach $astParameters -Skip:(-not ($parameters -and $astParameters.Ast)) {
            $Parameters.Name.Count | Should -Be $Ast.Body.ParamBlock.Parameters.Count -Because 'the number of parameters in the help should match the number in the function script'
        }

        It 'Should have a description for <Name> parameter' -ForEach $parameters -Skip:(-not $parameters) {
            $Description | Should -Not -BeNullOrEmpty -Because "parameter $Name should have a description"
        }

        It "Should have a description for $command example" -ForEach $fullHelp.Examples.Example {
            param ($Example = $_)
            $Example.Remarks | Should -Not -BeNullOrEmpty -Because "example title should have a description!"
        }
    }
}
