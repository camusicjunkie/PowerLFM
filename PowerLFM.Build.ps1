#$Script:ModuleName = Get-ChildItem .\*\*.psm1 | Select-object -ExpandProperty BaseName
#$Script:CodeCoveragePercent = 0.0 # 0 to 1
#. $BuildRoot\BuildTasks\InvokeBuildInit.ps1

Enter-Build {
    Write-Verbose "Initializing build variables" -Verbose
    Write-Verbose "  Existing BuildRoot [$BuildRoot]" -Verbose

    $ModuleName = Get-ChildItem .\*\*.psm1 | Select-object -ExpandProperty BaseName
    $Script:CodeCoveragePercent = 0.0 # 0 to 1

    $Script:DocsPath = Join-Path -Path $BuildRoot -ChildPath 'docs'
    Write-Verbose "  DocsPath [$DocsPath]" -Verbose

    $script:Output = Join-Path -Path $BuildRoot -ChildPath 'output'
    Write-Verbose "  Output [$Output]" -Verbose

    $script:Source = Join-Path -Path $BuildRoot -ChildPath $ModuleName
    Write-Verbose "  Source [$Source]" -Verbose

    $script:Destination = Join-Path -Path $Output -ChildPath $ModuleName
    Write-Verbose "  Destination [$Destination]" -Verbose

    $Script:ManifestPath = Join-Path -Path $Destination -ChildPath "$ModuleName.psd1"
    Write-Verbose "  ManifestPath [$ManifestPath]" -Verbose

    $script:ModulePath = Join-Path -Path $Destination -ChildPath "$ModuleName.psm1"
    Write-Verbose "  ModulePath [$ModulePath]" -Verbose

    $script:Folders = 'Classes', 'Includes', 'Internal', 'Private', 'Public', 'Resources'
    Write-Verbose "  Folders [$Folders]" -Verbose

    $Script:TestFile = "$BuildRoot\Output\TestResults_PS$PSVersion`_$TimeStamp.xml"
    Write-Verbose "  TestFile [$TestFile]" -Verbose

    $Script:PSRepository = 'PSGallery'
    Write-Verbose "  PSRepository [$TestFile]" -Verbose
}

#$Output = Join-Path -Path $BuildRoot -ChildPath 'output'
#$Destination = Join-Path -Path $Output -ChildPath $ModuleName
#$ModulePath = Join-Path -Path $Destination -ChildPath "$ModuleName.psm1"

task Default Build, Test, UpdateSource
task Build Copy, Compile, BuildModule, BuildManifest, SetVersion
task Helpify GenerateMarkdown, GenerateHelp
task Test Build, ImportModule, Pester
task Publish Build, PublishVersion, Test, PublishModule
task TFS Clean, Build, PublishVersion, Test
task DevTest ImportDevModule, Pester

task buildModule2 @{
    Inputs  = (Get-ChildItem -Path $Source -Recurse -Filter *.ps1)
    Outputs = $ModulePath
    Jobs    = { New-Item $ModulePath -Force}
}

Write-Host 'Import common tasks'
Get-ChildItem -Path $BuildRoot\BuildTasks\*.Task.ps1 |
    ForEach-Object {Write-Host $_.FullName;. $_.FullName}
