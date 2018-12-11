$projectRoot = Resolve-Path "$PSScriptRoot\.."
$moduleName = Split-Path $projectRoot -Leaf
$moduleRoot = "$projectRoot\$moduleName"
$moduleManifestName = "$moduleName.psd1"
$moduleManifestPath = "$moduleRoot\$moduleManifestName"

Describe 'Module Tests' {
    Context 'ModuleManifest' {
        It 'Passes Test-ModuleManifest' {
            Test-ModuleManifest -Path $moduleManifestPath | Should Not BeNullOrEmpty
            $? | Should Be $true
        }
    }
    Context 'General project validation' {
        $scripts = Get-ChildItem $projectRoot -Include *.ps1, *.psm1, *.psd1 -Recurse

        # TestCases are splatted to the script so we need hashtables
        $testCase = $scripts | Foreach-Object{@{file = $_}}
        It "Script <file> should be valid powershell" -TestCases $testCase {
            param($file)

            $file.fullname | Should Exist

            $contents = Get-Content -Path $file.fullname -ErrorAction Stop
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
            $errors.count | Should Be 0
        }

        It "Module '$moduleName' can import cleanly" {
            {Import-Module (Join-Path $moduleRoot "$moduleName.psm1") -Force} | Should Not Throw
        }
    }
}
