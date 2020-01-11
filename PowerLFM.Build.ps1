#requires -Modules InvokeBuild

[CmdletBinding()]
param(
    [string[]]
    $Tag,

    [string]
    $PSGalleryAPIKey,

    [string]
    $GithubAccessToken
)

$WarningPreference = "Continue"
if ($PSBoundParameters.ContainsKey('Verbose')) {
    $VerbosePreference = "Continue"
}
if ($PSBoundParameters.ContainsKey('Debug')) {
    $DebugPreference = "Continue"
}

Enter-Build {
    git config --global user.email '33888807+camusicjunkie@users.noreply.github.com'
    git config --global user.name 'John Steele'
    git config --global credential.helper "store --file ~\.git-credentials"

    Set-BuildEnvironment -Force

    $env:BHBuildModulePath = "$env:BHBuildOutput\$env:BHProjectName\$env:BHProjectName.psm1"
    $env:BHBuildManifestPath = "$env:BHBuildOutput\$env:BHProjectName\$env:BHProjectName.psd1"
    $OS = (Get-CimInstance -ClassName Win32_OperatingSystem).Caption
    $OSVersion = (Get-CimInstance -ClassName Win32_OperatingSystem).Version

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
task . ShowInfo, Build, Test, CleanBuild

# Synopsis: Build a shippable release
task Build GenerateExternalHelp, CopyModuleFiles, CreateManifest, CompileModule

# Synopsis: Run all tests
task Test Build, RunPester, PublishTestToAppveyor

#task Deploy

# Synopsis: Get the next build version
task GetNextVersion {
    use "$env:BHBuildOutput\downloads\GitVersion.CommandLine\tools" gitversion

    $gitversion = exec { gitversion | ConvertFrom-Json }
    $env:NextBuildVersion = $gitversion.MajorMinorPatch
}

# Synopsis: Display build information
task ShowInfo GetNextVersion, {
    Write-Build Gray
    Write-Build Gray ('Running in:                 {0}' -f $env:BHBuildSystem)
    Write-Build Gray '-------------------------------------------------------'
    Write-Build Gray
    Write-Build Gray ('Project name:               {0}' -f $env:BHProjectName)
    Write-Build Gray ('Project root:               {0}' -f $env:BHProjectPath)
    Write-Build Gray ('Build Path:                 {0}' -f $env:BHBuildOutput)
    Write-Build Gray ('Build Manifest Path:        {0}' -f $env:BHBuildManifestPath)
    Write-Build Gray ('Build Module Path:          {0}' -f $env:BHBuildModulePath)
    Write-Build Gray ('Current (online) Version:   {0}' -f $env:CurrentOnlineVersion)
    Write-Build Gray '-------------------------------------------------------'
    Write-Build Gray
    Write-Build Gray ('Branch:                     {0}' -f $env:BHBranchName)
    Write-Build Gray ('Commit:                     {0}' -f $env:BHCommitMessage)
    Write-Build Gray ('Build #:                    {0}' -f $env:BHBuildNumber)
    Write-Build Gray ('Next Version:               {0}' -f $env:NextBuildVersion)
    Write-Build Gray '-------------------------------------------------------'
    Write-Build Gray
    Write-Build Gray ('PowerShell version:         {0}' -f $PSVersionTable.PSVersion.ToString())
    Write-Build Gray ('OS:                         {0}' -f $OS)
    Write-Build Gray ('OS Version:                 {0}' -f $OSVersion)
    Write-Build Gray
}

# Synopsis: Generate external help for each public function
task GenerateExternalHelp {
    $neParams = @{
        Path = "$env:BHProjectPath\docs"
        OutputPath = "$env:BHBuildOutput\$env:BHProjectName\$PSCulture"
        Force = $true
    }
    $null = New-ExternalHelp @neParams
}

# Synopsis: Copy module files to the build output folder
task CopyModuleFiles {
    # Setup
    $null = New-Item -Path "$env:BHBuildOutput\$env:BHProjectName\bin" -ItemType Directory -Force

    # Copy module
    Copy-Item -Path "$env:BHModulePath\*" -Destination "$env:BHBuildOutput\$env:BHProjectName" -Recurse -Force

    # Copy additional files
    Copy-Item -Path @(
        "$env:BHProjectPath\LICENSE"
        "$env:BHProjectPath\README.md"
    ) -Destination "$env:BHBuildOutput\$env:BHProjectName" -Force

    Invoke-PSDepend -Tags Copy -Confirm:$false
}

# Synopsis: Update the manifest of the build output module
task CreateManifest GetNextVersion, {
    Remove-Module $env:BHProjectName -ErrorAction SilentlyContinue
    Import-Module $env:BHPSModuleManifest -Force

    $public = @(Get-ChildItem -Path "$env:BHBuildOutput\$env:BHProjectName\Public\*.ps1" -ErrorAction SilentlyContinue)

    $nmmParams = @{
        Path = $env:BHBuildManifestPath
        RootModule = 'PowerLFM.psm1'
        ModuleVersion = $env:NextBuildVersion
        Author = 'John Steele'
        Description = 'Module to leverage the Last.fm API'
        RequiredAssemblies = 'bin\Newtonsoft.Json.dll'
        FunctionsToExport = $public.BaseName
        CmdletsToExport = @()
        AliasesToExport = @()
        Tags = 'Last.FM','LastFM','API','Rest','Json'
        LicenseUri = 'https://github.com/camusicjunkie/PowerLFM/blob/master/LICENSE'
        ProjectUri = 'https://github.com/camusicjunkie/PowerLFM'
    }
    New-ModuleManifest @nmmParams
}

# Synopsis: Compile all functions into the build output module file
task CompileModule {
    $regionsToKeep = @('Init', 'Variables')

    $content = Get-Content -Encoding UTF8 -LiteralPath $env:BHBuildModulePath
    $capture = $false
    $compiled = ''

    #captures all content between #region\#endregion tags in $regionsToKeep
    $compiled = foreach ($line in $content) {
        if ($capture) { $line -replace '^#endregion.+'}
        if ($line -match "^#region ($($regionsToKeep -join "|"))$") { $capture = $true }
        if (($capture -eq $true) -and ($line -match "^#endregion")) { $capture = $false }
    }

    $public = @(Get-ChildItem -Path "$env:BHBuildOutput\$env:BHProjectName\Public\*.ps1" -ErrorAction SilentlyContinue)
    $private = @(Get-ChildItem -Path "$env:BHBuildOutput\$env:BHProjectName\Private\*.ps1" -ErrorAction SilentlyContinue)

    $content = foreach ($function in @($public + $private)) {
        Get-Content -Path $function.FullName -Raw
    }

    Set-Content -LiteralPath $env:BHBuildModulePath -Value @($compiled, $content) -Encoding UTF8 -Force
}

# Synopsis: Copy test files to the build output folder
task CopyTestFiles {
    Copy-Item -Path "$env:BHProjectPath\Tests" -Destination $env:BHBuildOutput -Recurse -Force
    Copy-Item -Path "$env:BHProjectPath\config" -Destination $env:BHBuildOutput -Recurse -Force
    $null = New-Item -Path "$env:BHBuildOutput\testResults" -ItemType Directory
}

# Synopsis: Run all Pester tests
task RunPester CopyTestFiles, {
    assert { Test-Path $env:BHBuildOutput -PathType Container } "Build output path must exist"
    Remove-Module $env:BHProjectName -ErrorAction SilentlyContinue

    $timestamp = Get-Date -UFormat "%Y%m%d-%H%M%S"

    $ipParams = @{
        Script       = "$env:BHBuildOutput\Tests\"
        Tag          = $Tag
        Show         = 'Failed', 'Summary'
        PassThru     = $true
        OutputFile   = "$env:BHBuildOutput\testResults\Test-{0}-{1}.xml" -f $PSVersionTable.PSVersion, $timestamp
        OutputFormat = 'NUnitXml'
    }
    $testResults = Invoke-Pester @ipParams

    assert ($testResults.FailedCount -eq 0) "$($testResults.FailedCount) Pester test(s) failed."
}

# Synopsis: Publish tests to Appveyor
task PublishTestToAppveyor -If ($env:APPVEYOR) {
    assert { Test-Path -Path "$env:BHBuildOutput\testResults" }

    $TestResultFiles = Get-ChildItem -Path "$env:BHBuildOutput\testResults" -Filter *.xml
    $TestResultFiles | Add-TestResultToAppveyor
}

# Synopsis: Remove private/public folders from module in the build output folder
task CleanBuild CompileModule, {
    "Private", "Public" | Foreach-Object { Remove-Item -Path "$env:BHBuildOutput\$env:BHProjectName\$_" -Recurse -Force }
}

# Synopsis: Empty task that's useful to test the bootstrap process
task Noop { }
