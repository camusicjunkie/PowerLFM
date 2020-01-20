#requires -Modules InvokeBuild

[CmdletBinding()]
param(
    [string[]]
    $Tag,

    [string]
    $NuGetApiKey,

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
    git config --global credential.helper store

    Set-BuildEnvironment -Force

    $env:BHBuildModulePath = "$env:BHBuildOutput\$env:BHProjectName\$env:BHProjectName.psm1"
    $env:BHBuildManifestPath = "$env:BHBuildOutput\$env:BHProjectName\$env:BHProjectName.psd1"
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

    Write-Host 'Checking if github token is null'
    Write-Host ($null -eq $env:GithubPAT)
}

# Synopsis: Default task
Task . Clean, Build, Test, Publish

# Synopsis: Remove old build files
Task Clean RemoveTestResults

# Synopsis: Build a shippable release
Task Build Clean, ShowInfo, GenerateExternalHelp, CopyModuleFiles, CreateManifest, CompileModule

# Synopsis: Run all tests
Task Test Build, RunPester, CleanBuild, PublishTestToAppveyor

# Synopsis: Publish
Task Publish Test, PublishToGitHub, PublishToLocalGallery

# Synopsis: Import module
Task ImportModule {
    Import-Module $env:BHBuildManifestPath -Force
}

# Synopsis: Get the next build version
Task GetNextVersion {
    Use "$env:BHBuildOutput\downloads\GitVersion.CommandLine\tools" gitversion

    $gitversion = Exec { gitversion | ConvertFrom-Json }
    $env:NextBuildVersion = $gitversion.MajorMinorPatch
}

# Synopsis: Display build information
Task ShowInfo GetNextVersion, {
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
Task GenerateExternalHelp {
    $neParams = @{
        Path       = "$env:BHProjectPath\docs"
        OutputPath = "$env:BHBuildOutput\$env:BHProjectName\$PSCulture"
        Force      = $true
    }
    $null = New-ExternalHelp @neParams
}

# Synopsis: Copy module files to the build output folder
Task CopyModuleFiles {
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
Task CreateManifest GetNextVersion, {
    $public = @(Get-ChildItem -Path "$env:BHBuildOutput\$env:BHProjectName\Public\*.ps1" -ErrorAction SilentlyContinue)

    $nmmParams = @{
        Path               = $env:BHBuildManifestPath
        RootModule         = 'PowerLFM.psm1'
        ModuleVersion      = $env:NextBuildVersion
        Author             = 'John Steele'
        Description        = 'Module to leverage the Last.fm API'
        RequiredAssemblies = 'bin\Newtonsoft.Json.dll'
        FunctionsToExport  = $public.BaseName
        CmdletsToExport    = @()
        AliasesToExport    = @()
        Tags               = 'Last.FM', 'LastFM', 'API', 'Rest', 'Json'
        LicenseUri         = 'https://github.com/camusicjunkie/PowerLFM/blob/master/LICENSE'
        ProjectUri         = 'https://github.com/camusicjunkie/PowerLFM'
    }
    New-ModuleManifest @nmmParams
}

# Synopsis: Compile all functions into the build output module file
Task CompileModule {
    $regionsToKeep = @('Init', 'Variables')

    $content = Get-Content -Encoding UTF8 -LiteralPath $env:BHBuildModulePath
    $capture = $false
    $compiled = ''

    #captures all content between #region\#endregion tags in $regionsToKeep
    $compiled = foreach ($line in $content) {
        if ($capture) { $line -replace '^#endregion.+' }
        if ($line -match "^#region ($($regionsToKeep -join "|"))$") { $capture = $true }
        if (($capture -eq $true) -and ($line -match "^#endregion")) { $capture = $false }
    }

    $public = @(Get-ChildItem -Path "$env:BHBuildOutput\$env:BHProjectName\Public\*.ps1" -ErrorAction SilentlyContinue)
    $private = @(Get-ChildItem -Path "$env:BHBuildOutput\$env:BHProjectName\Private\*.ps1" -ErrorAction SilentlyContinue)

    $content = foreach ($function in @($public + $private)) {
        Get-Content -Path $function.FullName -Raw
    }

    Set-Content -LiteralPath $env:BHBuildModulePath -Value $compiled, $content -Encoding UTF8 -Force
}, ImportModule

# Synopsis: Copy test files to the build output folder
Task CopyTestFiles {
    Copy-Item -Path "$env:BHProjectPath\Tests" -Destination $env:BHBuildOutput -Recurse -Force
    Copy-Item -Path "$env:BHProjectPath\config" -Destination $env:BHBuildOutput -Recurse -Force
    $null = New-Item -Path "$env:BHBuildOutput\testResults" -ItemType Directory -Force
}

# Synopsis: Run all Pester tests
Task RunPester CopyTestFiles, {
    Assert { Test-Path $env:BHBuildOutput -PathType Container } "Build output path must exist"
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

    Equals $testResults.FailedCount 0
}

# Synopsis: Publish tests to Appveyor
Task PublishTestToAppveyor -If ($env:APPVEYOR) {
    Assert { Test-Path -Path "$env:BHBuildOutput\testResults" } "Test results path must exist"

    $TestResultFiles = Get-ChildItem -Path "$env:BHBuildOutput\testResults" -Filter *.xml
    $TestResultFiles | Add-TestResultToAppveyor
}

# Synopsis: Remove private/public folders from module in the build output folder
Task CleanBuild CompileModule, {
    "Private", "Public" | ForEach-Object { Remove "$env:BHBuildOutput\$env:BHProjectName\$_" }
}

# Synopsis: Create a ZIP file from this build
Task Package {
    Write-Build Gray "  Creating Release ZIP..."

    $caParams = @{
        Path = "$env:BHBuildOutput\$env:BHProjectName"
        DestinationPath = "$env:BHBuildOutput\downloads\$env:BHProjectName.zip"
        Force = $true
    }
    Compress-Archive @caParams
}

# Synopsis: Remove Pester results
Task RemoveTestResults {
    Remove "$env:BHBuildOutput\testResults\Test-*.xml"
}

$gitHubConditions = {
   -not [String]::IsNullOrEmpty($GithubAccessToken) -and
   -not [String]::IsNullOrEmpty($env:NextBuildVersion) -and
   $env:BHBuildSystem -eq 'APPVEYOR' -and
   $env:BHCommitMessage -match '!deploy' -and
   $env:BHBranchName -eq "master"
}

# Synopsis: Publish module to Github Releases
Task PublishToGitHub -If $gitHubConditions GetNextVersion, Package, {
    # Add GithubPAT to the git credentials store file
    Add-Content "$HOME\.git-credentials" "https://$($env:GithubPAT):x-oauth-basic@github.com`n"

    # Push a tag to the repository
    Write-Build Gray "  git checkout $ENV:BHBranchName"
    $null = cmd /c "git checkout $ENV:BHBranchName 2>&1"

    Write-Build Gray "  git tag -a v$env:NextBuildVersion -m 'PowerLFM Release v$env:NextBuildVersion'"
    $null = cmd /c "git tag -a v$env:NextBuildVersion -m "PowerLFM Release v$env:NextBuildVersion" 2>&1"

    Write-Build Gray "  git push origin v$env:NextBuildVersion"
    $null = cmd /c "git push origin v$env:NextBuildVersion 2>&1"

    Write-Build Gray "  Publishing Release v$env:NextBuildVersion to GitHub..."

    $gitHubParams = @{
        Name            = "PowerLFM v$env:NextBuildVersion"
        TagName         = "v$env:NextBuildVersion"
        ReleaseText     = "PowerLFM Release v$env:NextBuildVersion"
        RepositoryOwner = 'camusicjunkie'
        RepositoryName  = $env:BHProjectName
        AccessToken     = $GithubAccessToken
        Artifact        = "$env:BHBuildOutput\downloads\$env:BHProjectName.zip"
    }
    $null = Publish-GithubRelease @gitHubParams

    Write-Build Gray "  Github release created."
}

$localGalleryConditions = {
    -not [String]::IsNullOrEmpty($NuGetApiKey) -and
    -not [String]::IsNullOrEmpty($env:NextBuildVersion) -and
    (Get-Module $env:BHProjectName).Version -gt
    (Find-Module $env:BHProjectName -Repository Local -ErrorAction SilentlyContinue).Version -and
    $env:BHBuildSystem -eq 'Unknown'
}

# Synopsis: Publish module to local NuGet repository
Task PublishToLocalGallery -If $localGalleryConditions {
    Assert {Get-Module -Name $env:BHProjectName} "Module $env:BHProjectName is not available"

    $ipdParams = @{
        Deployment = (Get-PSDeployment -Path "PowerLFM.psdeploy.ps1")
        Tags = 'Local'
        Force = $true
        DeploymentParameters = @{
            PSGalleryModule = @{
                ApiKey = $NuGetApiKey
            }
        }
    }
    Invoke-PSDeployment @ipdParams
}

# Synopsis: Empty task that's useful to test the bootstrap process
Task Noop { }
