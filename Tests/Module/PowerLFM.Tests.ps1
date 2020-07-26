$projectRoot = Resolve-Path "$PSScriptRoot\..\.."
$moduleName = 'PowerLFM'
$moduleRoot = "$projectRoot\$moduleName"
$moduleManifestName = "$moduleName.psd1"
$moduleManifestPath = "$moduleRoot\$moduleManifestName"

$public = @(Get-ChildItem -Path $moduleRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
$private = @(Get-ChildItem -Path $moduleRoot\Private\*.ps1 -ErrorAction SilentlyContinue)

Remove-Module -Name $moduleName -ErrorAction Ignore
Import-Module -Name $moduleManifestPath

if (Get-Command Invoke-ScriptAnalyzer -ErrorAction SilentlyContinue) {
    $scriptAnalyzerRules = Get-ScriptAnalyzerRule -Severity Error, Warning
}
else {
    if ($ErrorActionPreference -ne 'Stop') {
        Write-Warning 'ScriptAnalyzer not found!'
    }
    else {
        throw 'ScriptAnalyzer not found!'
    }
}

Describe 'Module Tests' {

    Context 'General project validation' {

        It 'Module manifest should exist and be valid' {
            if (-not (Test-Path "$moduleRoot\lib\newtonsoft.json.dll")) {
                Set-ItResult -Pending -Because 'the build process needs to be updated to copy the dll over to the bin folder'
            }

            Test-ModuleManifest -Path $moduleManifestPath | Should -Not -BeNullOrEmpty
            $? | Should Be $true
        }

        It "Module '$moduleName' can import cleanly" {
            { Import-Module (Join-Path $moduleRoot "$moduleName.psm1") -Force } | Should -Not -Throw
        }
    }

    Context 'Function quality checks' {

        $scripts = Get-ChildItem -Path @($public + $private)
        $testCases = $scripts | ForEach-Object { @{ FileName = $_.BaseName; FullName = $_.FullName } }

        if ($scriptAnalyzerRules) {
            It 'Should pass script analyzer checks for <FileName>' -TestCases $testCases {
                param ($FullName)

                (Invoke-ScriptAnalyzer -Path $FullName -IncludeRule $scriptAnalyzerRules).count | Should -Be 0
            }
        }

        It 'Should have a unit test for <FileName>' -TestCases $testCases {
            param ($FileName, $FullName)

            if ($FullName -like '*\Private\*') {
                Set-ItResult -Pending -Because "a test for the private function doesn't exist yet"
            }

            Get-Content "$projectRoot\Tests\$FileName.tests.ps1" | Should -Not -BeNullOrEmpty
        }
    }

    Context "Public function help checks" {

        $scripts = Get-ChildItem -Path $public
        $testCases = $scripts | ForEach-Object { @{ FileName = $_.BaseName } }

        It 'Should have a description for <FileName>' -TestCases $testCases {
            param ($FileName)

            $help = Get-Help $FileName
            $help.Description.Text | Should -Not -BeNullOrEmpty
        }

        It 'Should have at least one example for <FileName>' -TestCases $testCases {
            param ($FileName)

            $help = Get-Help $FileName
            $help.Examples | Should Not BeNullOrEmpty
            $help.Examples[0].Example.Code | Should -Match $help.Name
        }

        foreach ($fileName in $scripts.BaseName) {
            $help = Get-Help $fileName
            $parameters = $help.Parameters.Parameter

            foreach ($parameter in $parameters) {
                if ($parameter -notmatch 'WhatIf|Confirm') {
                    It "Should have a description for parameter $($parameter.Name) in $fileName" {
                        $parameter.Description.Text | Should Not BeNullOrEmpty
                    }
                }
            }
        }
    }
}
