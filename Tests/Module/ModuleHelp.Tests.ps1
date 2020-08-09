Describe 'Public function help checks' -Tag Module {

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

        Context "[$command] help content validation" {

            #region Discovery

            $help = @{ Help = Get-Help -Name $command -Full | Select-Object -Property * }
            $parameters = Get-Help -Name $command -Parameter * -ErrorAction Ignore |
                Where-Object { $_.Name -and $_.Name -notin $shouldProcessParameters } |
                ForEach-Object { @{ Name = $_.name; Description = $_.Description.Text } }

            $ast = @{
                # Ast will be $null if the command is a compiled cmdlet
                Ast        = (Get-Content -Path "function:/$command" -ErrorAction Ignore).Ast
                Parameters = $parameters
            }

            $examples = $help.Help.Examples.Example | ForEach-Object { @{ Example = $_ } }

            #endregion Discovery

            It "Should have help content for $command" -TestCases $help {
                $help | Should -Not -BeNullOrEmpty
            }

            It "Should contain a synopsis for $command" -TestCases $help {
                $help.Synopsis | Should -Not -BeNullOrEmpty
            }

            It "Should contain a description for $command" -TestCases $help {
                $help.Description | Should -Not -BeNullOrEmpty
            }

            It "Should have at least one usage example for $command" -TestCases $help {
                $help.Examples.Example.Code.Count | Should -BeGreaterOrEqual 1
            }

            # This will be skipped for compiled commands ($ast.Ast will be $null)
            It "Should have a help entry for all parameters of $command" -TestCases $ast -Skip:(-not ($parameters -and $ast.Ast)) {
                @($parameters).Count | Should -Be $ast.Body.ParamBlock.Parameters.Count -Because 'the number of parameters in the help should match the number in the function script'
            }

            It "Should have a description for $command parameter -<Name>" -TestCases $parameters -Skip:(-not $parameters) {
                $Description | Should -Not -BeNullOrEmpty -Because "parameter $Name should have a description"
            }

            It "Should have a description for $command example" -TestCases $examples {
                $example.Remarks | Should -Not -BeNullOrEmpty -Because "example title should have a description!"
            }
        }
    }
}
