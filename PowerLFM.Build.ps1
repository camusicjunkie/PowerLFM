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
}

# Synopsis: Get the next build version
Task GetNextVersion {
    use "$env:BHBuildOutput\downloads\GitVersion.CommandLine\tools" gitversion

    $gitversion = exec { gitversion | ConvertFrom-Json }
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

Task Build CopyModuleFiles, UpdateManifest, CompileModule, CleanBuild

# Synopsis: Generate external help for each public function
task GenerateExternalHelp {
    $neParams = @{
        Path = "$env:BHProjectPath\docs"
        OutputPath = "$env:BHBuildOutput\$env:BHProjectName\$PSCulture"
        Force = $true
    }
    $null = New-ExternalHelp @neParams
}

# Synopsis: Copy module files over to build output folder
task CopyModuleFiles {
    # Setup
    if (-not (Test-Path "$env:BHBuildOutput\$env:BHProjectName")) {
        $null = New-Item -Path "$env:BHBuildOutput\$env:BHProjectName" -ItemType Directory
    }

    # Copy module
    Copy-Item -Path "$env:BHModulePath\*" -Destination "$env:BHBuildOutput\$env:BHProjectName" -Recurse -Force

    # Copy additional files
    Copy-Item -Path @(
        "$env:BHProjectPath\LICENSE"
        "$env:BHProjectPath\README.md"
    ) -Destination "$env:BHBuildOutput\$env:BHProjectName" -Force

    Invoke-PSDepend -Tags Copy -Confirm:$false
}

# Synopsis: Update the manifest of the module
task UpdateManifest GetNextVersion, {
    Remove-Module $env:BHProjectName -ErrorAction SilentlyContinue
    Import-Module $env:BHPSModuleManifest -Force

    $public = @(Get-ChildItem -Path "$env:BHBuildOutput\$env:BHProjectName\Public\*.ps1" -ErrorAction SilentlyContinue)

    $ummParams = @{
        Path = $env:BHBuildManifestPath
        FunctionsToExport = $public.BaseName
        ModuleVersion = $env:NextBuildVersion
    }
    Update-ModuleManifest @ummParams
}

# Synopsis: Compile all functions into the .psm1 file
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

task CleanBuild CompileModule, {
    "Private", "Public" | Foreach-Object { Remove-Item -Path "$env:BHBuildOutput/$env:BHProjectName/$_" -Recurse -Force }
}

task Clean -If (Get-ChildItem $env:BHBuildOutput -Exclude downloads, modules) {
    remove (Get-ChildItem $env:BHBuildOutput -Exclude downloads, modules -ErrorAction SilentlyContinue)
}

Task . ShowInfo, Clean, Build #, Test

# Task Test

# Task Deploy
