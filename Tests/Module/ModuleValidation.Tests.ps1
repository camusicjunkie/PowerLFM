Describe 'Static Analysis: Module & Repository Files' {

    #region Discovery

    $moduleName = 'PowerLFM'
    $projectRoot = Resolve-Path "$PSScriptRoot\..\.."

    $fileSearch = @{
        Path    = Resolve-Path $projectRoot\$moduleName
        Include = '*.ps1', '*.psm1', '*.psd1'
        Recurse = $true
    }
    $scripts = Get-ChildItem @fileSearch
    $testCases = $scripts | ForEach-Object { @{ FileName = $_.BaseName; FullName = $_.FullName } }

    $moduleManifestPath = "$projectRoot\$moduleName\$moduleName.psd1"
    Import-Module $moduleManifestPath

    #endregion Discovery

    Context 'Repository code' {

        It 'Should have no invalid syntax errors in <FileName>' -TestCases $testCases {
            $FullName | Should -Exist

            $fileContents = Get-Content -Path $FullName -ErrorAction Stop
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($fileContents, [ref]$errors)
            $errors.Count | Should -Be 0
        }

        It 'Should have exactly one line feed at EOF in <FileName>' -TestCases $testCases {
            $crlf = [Regex]::Match((Get-Item $FullName | Get-Content -Raw), '(\r?(?<lf>\n))+\Z')
            $crlf.Groups['lf'].Captures.Count | Should -Be 1
        }
    }

    Context 'Module import' {

        BeforeAll {
            $moduleName = 'PowerLFM'
            $projectRoot = Resolve-Path "$PSScriptRoot\..\.."
            $moduleManifestPath = "$projectRoot\$moduleName\$moduleName.psd1"
        }

        It 'Should cleanly import the module' {
            { Import-Module $moduleManifestPath -Force } | Should -Not -Throw
        }

        It 'Should remove and re-import the module without errors' {
            $script = {
                Remove-Module $moduleName
                Import-Module $moduleManifestPath
            }

            $script | Should -Not -Throw
        }
    }

    Context 'Test files' {

        #region Discovery

        $module = Get-Module $moduleName
        $commands = @($module.ExportedFunctions.Keys)
        $testCases = $commands | ForEach-Object {  @{ FileName = $_ } }

        #endregion Discovery

        BeforeAll {
            $projectRoot = Resolve-Path "$PSScriptRoot\..\.."
        }

        It 'Should have a unit test for <FileName>' -TestCases $testCases {
            Get-Content "$projectRoot\Tests\$FileName.tests.ps1" | Should -Not -BeNullOrEmpty
        }
    }
}
