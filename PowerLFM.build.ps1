#requires -Modules InvokeBuild

[CmdletBinding()]
param(
    [string[]]
    $Tag,

    # Test files or folders for QuickTest; all of source\tests when not given
    [string[]]
    $TestPath,

    [string]
    $NuGetApiKey
)

Enter-Build {
    $script:OS = (Get-CimInstance -ClassName Win32_OperatingSystem).Caption
    $script:OSVersion = (Get-CimInstance -ClassName Win32_OperatingSystem).Version

    Set-BuildHeader {
        param($Path)
        ''
        '=' * 79
        Write-Build Cyan "$($Task.Name)"
        ''
        Write-Build DarkGray  "$(Get-BuildSynopsis $Task)"
        '-' * 79
        Write-Build DarkGray "  $Path"
        Write-Build DarkGray "  $($Task.InvocationInfo.ScriptName):$($Task.InvocationInfo.ScriptLineNumber)"
        ''
    }
}

# Synopsis: Default task
Task . Clean, Analyze, Build, Test

# Synopsis: Get the next build version
Task GetNextVersion {
    $gitversion = Exec { gitversion | ConvertFrom-Json }
    $env:NextBuildVersion = $gitversion.MajorMinorPatch
}

# Synopsis: Display build information
Task ShowInfo {
    Write-Build Gray ('PowerShell version:         {0}' -f $PSVersionTable.PSVersion.ToString())
    Write-Build Gray ('OS:                         {0}' -f $OS)
    Write-Build Gray ('OS Version:                 {0}' -f $OSVersion)
    Write-Build Gray
}

# Synopsis: Remove old build files
Task Clean {
    if (Test-Path "$PSScriptRoot\build") {
        Remove-Item "$PSScriptRoot\build" -Recurse -Force
    }
}

# Synopsis: Build a shippable release
Task Build GetNextVersion, {
    Build-Module -Path "$PSScriptRoot\source\build.psd1" -Version $env:NextBuildVersion
}

# Synopsis: Run all Pester tests
Task Test {
    Import-Module -Name Pester -MinimumVersion 6.0.0 -Force

    $modulePath = Get-Item "$PSScriptRoot\build\*\*\*.psd1" | Where-Object {
        $_.BaseName -eq $_.Directory.Parent.Name
    }
    $rootModule = $modulePath -replace 'd1$', 'm1'

    Import-Module -Name $modulePath -Force -Global

    $configuration = New-PesterConfiguration
    $configuration.Run.Path = "$PSScriptRoot\source\Tests\"
    $configuration.Run.Passthru = $true
    $configuration.CodeCoverage.Enabled = $true
    $configuration.CodeCoverage.Path = $rootModule
    $configuration.CodeCoverage.OutputPath = "$PSScriptRoot\build\codecoverage.xml"
    $configuration.TestResult.Enabled = $true
    $configuration.TestResult.OutputPath = "$PSScriptRoot\build\testResults.xml"
    $configuration.Output.Verbosity = 'Detailed'
    if ($null -ne $Tag) { $configuration.Filter.Tag = $Tag }

    $testResults = Invoke-Pester -Configuration $configuration

    Equals $testResults.FailedCount 0
}

# Synopsis: Build at version 0.0.0 without GitVersion, for local test runs
Task DevBuild {
    # A second version beside an earlier build would make the module path below ambiguous
    if (Test-Path "$PSScriptRoot\build\PowerLFM") {
        Remove-Item "$PSScriptRoot\build\PowerLFM" -Recurse -Force
    }
    Build-Module -Path "$PSScriptRoot\source\build.psd1" -Version '0.0.0'
}

# Synopsis: Build, then run the given tests without coverage
Task QuickTest DevBuild, {
    Import-Module -Name Pester -MinimumVersion 6.0.0 -Force
    Import-Module -Name "$PSScriptRoot\build\PowerLFM\0.0.0\PowerLFM.psd1" -Force -Global

    $configuration = New-PesterConfiguration
    $configuration.Run.Path = if ($TestPath) { $TestPath } else { "$PSScriptRoot\source\tests\" }
    $configuration.Run.Passthru = $true
    $configuration.Output.Verbosity = 'Normal'
    if ($null -ne $Tag) { $configuration.Filter.Tag = $Tag }

    $testResults = Invoke-Pester -Configuration $configuration

    Equals $testResults.FailedCount 0
}

# Synopsis: Lint the module source with PSScriptAnalyzer
Task Analyze {
    # The tests are left out: Pester's BeforeAll scoping reads as unused variables
    $findings = foreach ($path in 'Private', 'Public', 'prefix.ps1') {
        Invoke-ScriptAnalyzer -Path "$PSScriptRoot\source\$path" -Recurse -Severity Warning, Error
    }

    if ($findings) {
        $findings | Format-Table RuleName, ScriptName, Line, Message -AutoSize -Wrap | Out-String -Width 200
        throw "PSScriptAnalyzer found $(@($findings).Count) issue(s)."
    }
}

# Synopsis: Generate external help for each public function
Task GenerateExternalHelp {
    $modulePath = Get-Item "$PSScriptRoot\build\*\*\*.psd1" | Where-Object {
        $_.BaseName -eq $_.Directory.Parent.Name
    }
    $neParams = @{
        Path       = "$PSScriptRoot\docs"
        OutputPath = "$($modulePath.Directory.FullName)\$PSCulture"
        Force      = $true
    }
    $null = New-ExternalHelp @neParams
}

# Synopsis: Publish
Task Publish PublishToPSGallery

# Synopsis: Publish module to the PSGallery
Task PublishToPSGallery {
    $modulePath = Get-Item -Path "$PSScriptRoot\build\*\*\*.psd1" |
        Where-Object { $_.BaseName -eq $_.Directory.Parent.Name } |
        Select-Object -ExpandProperty Directory

        $apiKey = if ($NuGetApiKey) { $NuGetApiKey } else { $env:NuGetApiKey }
        Write-Build Gray "  Publishing version [$($env:NextBuildVersion)] to PSGallery"
        Publish-Module -Path $modulePath.FullName -NuGetApiKey $apiKey -Repository PSGallery -ErrorAction Stop
}

# Synopsis: Empty task that's useful to test the bootstrap process
Task Noop { }
