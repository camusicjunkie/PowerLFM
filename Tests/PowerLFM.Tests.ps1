$projectRoot = Resolve-Path "$PSScriptRoot\.."
$moduleRoot = Split-Path (Resolve-Path "$projectRoot\*\*.psm1")
$moduleName = Split-Path $moduleRoot -Leaf
$ModuleManifestName = "$moduleName.psd1"
$ModuleManifestPath = "$PSScriptRoot\..\$moduleName\$ModuleManifestName"


Describe 'Module Tests' {
    Context 'ModuleManifest' {
        It 'Passes Test-ModuleManifest' {
            Test-ModuleManifest -Path $ModuleManifestPath | Should Not BeNullOrEmpty
            $? | Should Be $true
        }
    }
    Context 'General project validation' {
        $scripts = Get-ChildItem $projectRoot -Include *.ps1,*.psm1,*.psd1 -Recurse

        # TestCases are splatted to the script so we need hashtables
        $testCase = $scripts | Foreach-Object{@{file=$_}}         
        It "Script <file> should be valid powershell" -TestCases $testCase {
            param($file)
    
            $file.fullname | Should Exist
    
            $contents = Get-Content -Path $file.fullname -ErrorAction Stop
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
            $errors.Count | Should Be 0
        }
    
        It "Module '$moduleName' can import cleanly" {
            {Import-Module (Join-Path $moduleRoot "$moduleName.psm1") -force } | Should Not Throw
        }
    }
}