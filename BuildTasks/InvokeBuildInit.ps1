Write-Verbose "Initializing build variables" -Verbose
Write-Verbose "  Existing BuildRoot [$BuildRoot]" -Verbose

$script:DocsPath = Join-Path -Path $BuildRoot -ChildPath 'Docs'
Write-Verbose "  DocsPath [$DocsPath]" -Verbose

$script:Output = Join-Path -Path $BuildRoot -ChildPath 'Output'
Write-Verbose "  Output [$Output]" -Verbose

$script:Source = Join-Path -Path $BuildRoot -ChildPath $ModuleName
Write-Verbose "  Source [$Source]" -Verbose

$script:Destination = Join-Path -Path $Output -ChildPath $ModuleName
Write-Verbose "  Destination [$Destination]" -Verbose

$script:ManifestPath = Join-Path -Path $Destination -ChildPath "$ModuleName.psd1"
Write-Verbose "  ManifestPath [$ManifestPath]" -Verbose

$script:ModulePath = Join-Path -Path $Destination -ChildPath "$ModuleName.psm1"
Write-Verbose "  ModulePath [$ModulePath]" -Verbose

$script:Folders = 'Classes', 'Includes', 'Internal', 'Private', 'Public', 'Resources'
Write-Verbose "  Folders [$Folders]" -Verbose

$script:TestFile = "$BuildRoot\Output\TestResults_PS$PSVersion`_$TimeStamp.xml"
Write-Verbose "  TestFile [$TestFile]" -Verbose

$script:PSRepository = 'PSGallery'
Write-Verbose "  PSRepository [$TestFile]" -Verbose

#function taskx($Name, $Parameters) { task $Name @Parameters -Source $MyInvocation }
