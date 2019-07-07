$projectRoot = Resolve-Path "$PSScriptRoot\..\.."
$moduleName = Split-Path $projectRoot -Leaf
$moduleRoot = "$projectRoot\$moduleName"
$moduleManifestName = "$moduleName.psd1"
$moduleManifestPath = "$moduleRoot\$moduleManifestName"

Describe 'Module Tests' {
    It 'Module manifest should exist and be valid' {
        Test-ModuleManifest -Path $moduleManifestPath | Should -Not -BeNullOrEmpty
        $? | Should Be $true
    }

    It "Module '$moduleName' can import cleanly" {
        {Import-Module (Join-Path $moduleRoot "$moduleName.psm1") -Force} | Should -Not -Throw
    }

    Context 'General project validation' {
        $scripts = Get-ChildItem $projectRoot -Include *.ps1, *.psm1, *.psd1 -Recurse

        $testCases = $scripts | Foreach-Object { @{file = $_.Name} }

        It "Script <file> should be valid powershell" -TestCases $testCases {
            param($file)

            $fullName = (Get-ChildItem -Path $projectRoot -Include $file -Recurse -File).FullName
            $fullname | Should Exist

            $contents = Get-Content -Path $fullname -ErrorAction Stop
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
            $errors.count | Should Be 0
        }
    }
}
