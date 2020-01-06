#requires -Modules InvokeBuild

[CmdletBinding()]
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingWriteHost', '')]
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingEmptyCatchBlock', '')]
param(
    [Parameter(Position = 0)]
    $Tasks,
    [string[]]
    $Tag,
    [string]
    $PSGalleryAPIKey,
    [string]
    $GithubAccessToken,
    [switch]
    $ResolveDependency
)

$WarningPreference = "Continue"
if ($PSBoundParameters.ContainsKey('Verbose')) {
    $VerbosePreference = "Continue"
}
if ($PSBoundParameters.ContainsKey('Debug')) {
    $DebugPreference = "Continue"
}

Import-Module "$PSScriptRoot\BuildTools.psm1" -Force

if ($ResolveDependency) {
    Write-Host "Resolving Dependencies... [this can take a moment]"
    $rsParams = @{}
    if ($PSBoundParameters.ContainsKey('Verbose')) {
        $Params.Add('Verbose', $verbose)
    }
    Resolve-Dependency @rsParams
}

if ($MyInvocation.ScriptName -notlike '*Invoke-Build.ps1') {
    if ($PSBoundParameters.ContainsKey('ResolveDependency')) {
        Write-Verbose "Dependency already resolved. Skipping"
        $null = $PSBoundParameters.Remove('ResolveDependency')
    }

    Invoke-Build $Tasks $MyInvocation.MyCommand.Path @PSBoundParameters
    return
}

Enter-Build {
    Write-Build Yellow 'Build: Inside Enter-Build'
    Write-Host 'Host: Inside Enter-Build' -ForegroundColor Yellow
    Set-BuildEnvironment -Force
}

Task ShowInfo GetNextVersion, {
    Write-Build Gray
    Write-Build Gray ('Running in:                 {0}' -f $env:BHBuildSystem)
    Write-Build Gray '-------------------------------------------------------'
    Write-Build Gray
    Write-Build Gray ('Project name:               {0}' -f $env:BHProjectName)
    Write-Build Gray ('Project root:               {0}' -f $env:BHProjectPath)
    Write-Build Gray ('Build Path:                 {0}' -f $env:BHBuildOutput)
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
    #Write-Build Gray ('OS:                         {0}' -f $OS)
    #Write-Build Gray ('OS Version:                 {0}' -f $OSVersion)
    Write-Build Gray
}

Task GetNextVersion {
    $version = [version] '0.1.0'
    $publishedModule = $null
    $bumpVersionType = 'Patch'
    $versionStamp = (git rev-parse origin/master) + (git rev-parse head)

    Write-Build Gray "Load current version"
    [version] $sourceVersion = (Get-Metadata -Path $env:BHPSModuleManifest)
    #"  Source version [$sourceVersion]"

    $downloadFolder = Join-Path -Path $env:BHBuildOutput downloads
    $null = New-Item -ItemType Directory -Path $downloadFolder -Force -ErrorAction Ignore

    $versionFile = Join-Path $downloadFolder versionfile
    if (Test-Path $versionFile) {
        Write-Build Gray "$versionFile exists"
        $versionFileData = Get-Content $versionFile -raw
        if ($versionFileData -eq $versionStamp) {
            Write-Build Yellow 'Exiting task. Version file matches'
            continue
        }
    }

    Write-Build Gray -Text 'Checking for published version'
    $publishedModule = Find-Module -Name $env:BHProjectName -ErrorAction Ignore

    if ($null -ne $publishedModule) {
        [version] $publishedVersion = $publishedModule.Version
        Write-Build "  Published version [$publishedVersion]" -Color Cyan

        $version = $publishedVersion

        #"Downloading published module to check for breaking changes"
        $publishedModule | Save-Module -Path $downloadFolder

        [System.Collections.Generic.HashSet[string]] $publishedInterface = @(Get-ModuleInterfaceMap -Path (Join-Path $downloadFolder $env:BHProjectName))
        [System.Collections.Generic.HashSet[string]] $buildInterface = @(Get-ModuleInterfaceMap -Path $env:BHPSModuleManifest)

        $bumpVersionType = if (-not $publishedInterface.IsSubsetOf($buildInterface)) {
            'Major'
        }
        elseif ($publishedInterface.count -ne $buildInterface.count) {
            'Minor'
        }
    }

    if ($version -lt ([version] '1.0.0')) {
        #"Module is still in beta; don't bump major version."
        $bumpVersionType = if ($bumpVersionType -eq 'Major') { 'Minor' } else { 'Patch' }
    }

    #"  Stepping version [$bumpVersionType]"
    $version = [version] (Step-Version -Version $version -Type $bumpVersionType)

    #"  Comparing to source version [$sourceVersion]"
    if ($sourceVersion -gt $version) {
        #"    Using existing version"
        $version = $sourceVersion
    }

    if ( -not [string]::IsNullOrEmpty($env:Build_BuildID)) {
        $build = $env:Build_BuildID
        $version = [version]::new($version.Major, $version.Minor, $version.Build, $build)
    }
    elseif ( -not [string]::IsNullOrEmpty($env:APPVEYOR_BUILD_ID)) {
        #$build = $env:APPVEYOR_BUILD_ID
        #$version = [version]::new($version.Major, $version.Minor, $version.Build, $build)
    }

    #"  Setting version [$version]"
    # Update-Metadata -Path $env:BHPSModuleManifest -Value $version

    # Get-Content -Path $env:BHPSModuleManifest -Raw -Encoding UTF8 |
    #     ForEach-Object { $_.TrimEnd() } |
    #     Set-Content -Path $env:BHPSModuleManifest -Encoding UTF8

    #Set-Content -Path $versionFile -Value $versionStamp -NoNewline -Encoding UTF8
}

# task Default Build, Test, UpdateSource
# task Build Copy, Compile, BuildModule, BuildManifest, SetVersion
# task Helpify GenerateMarkdown, GenerateHelp
# task Test Build, ImportModule, Pester
# task Publish Build, PublishVersion, Test, PublishModule
# task TFS Clean, Build, PublishVersion, Test
# task DevTest ImportDevModule, Pester

# Write-Host 'Import common tasks'
# Get-ChildItem -Path $BuildRoot\BuildTasks\*.Task.ps1 |
#     ForEach-Object {Write-Host $_.FullName;. $_.FullName}
