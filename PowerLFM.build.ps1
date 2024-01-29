#requires -Modules InvokeBuild

[CmdletBinding()]
param(
    [string[]]
    $Tag,

    [string]
    $NuGetApiKey
)

Enter-Build {
    git config --global user.email '33888807+camusicjunkie@users.noreply.github.com'
    git config --global user.name 'John Steele'
    git config --global credential.helper store

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
Task . Clean, Build, Test

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
    $modulePath = Get-Item "$PSScriptRoot\build\*\*\*.psd1" | Where-Object {
        $_.BaseName -eq $_.Directory.Parent.Name
    }
    $rootModule = $modulePath -replace 'd1$', 'm1'

    Import-Module -Name $modulePath -Force -Global

    $configuration = @{
        Run          = @{ Path = "$PSScriptRoot\source\Tests\"; Passthru = $true }
        CodeCoverage = @{ Enabled = $true; Path = $rootModule; OutputPath = "$PSScriptRoot\build\codecoverage.xml" }
        TestResult   = @{ Enabled = $true; OutputPath = "$PSScriptRoot\build\testResults.xml" }
        Output       = @{ Verbosity = 'Detailed' }
    }
    if ($null -ne $Tag) { $config.Filter.Tag = $Tag }

    $testResults = Invoke-Pester -Configuration $configuration

    Equals $testResults.FailedCount 0
}

# Synopsis: Publish
Task Publish PublishToPSGallery

# Synopsis: Generate external help for each public function
Task GenerateExternalHelp {
    $neParams = @{
        Path       = "$PSScriptRoot\docs"
        OutputPath = "$PSScriptRoot\build\*\*\$PSCulture"
        Force      = $true
    }
    $null = New-ExternalHelp @neParams
}

$psGalleryConditions = {
    -not [String]::IsNullOrEmpty($NuGetApiKey) -and
    -not [String]::IsNullOrEmpty($env:NextBuildVersion) -and
    $env:BHBuildSystem -eq 'APPVEYOR' -and
    $env:BHCommitMessage -match '!deploy' -and
    $env:BHBranchName -eq "master"
}

# Synopsis: Publish module to the PSGallery
Task PublishToPSGallery -If $psGalleryConditions {
    Assert { Get-Module -Name $env:BHProjectName } "Module $env:BHProjectName is not available"

    Write-Build Gray "  Publishing version [$($env:NextBuildVersion)] to PSGallery"
    Publish-Module -Path $env:BHBuildOutput\$env:BHProjectName -NuGetApiKey $NuGetApiKey -Repository PSGallery
}

# Synopsis: Empty task that's useful to test the bootstrap process
Task Noop { }
