#requires -Modules InvokeBuild

[CmdletBinding()]
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingWriteHost', '')]
[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingEmptyCatchBlock', '')]
param(
    [String[]]$Tag,
    [String[]]$ExcludeTag = @("Integration"),
    [String]$PSGalleryAPIKey,
    [String]$GithubAccessToken
)

$WarningPreference = "Continue"
if ($PSBoundParameters.ContainsKey('Verbose')) {
    $VerbosePreference = "Continue"
}
if ($PSBoundParameters.ContainsKey('Debug')) {
    $DebugPreference = "Continue"
}


task Default Build, Test, UpdateSource
task Build Copy, Compile, BuildModule, BuildManifest, SetVersion
task Helpify GenerateMarkdown, GenerateHelp
task Test Build, ImportModule, Pester
task Publish Build, PublishVersion, Test, PublishModule
task TFS Clean, Build, PublishVersion, Test
task DevTest ImportDevModule, Pester

Write-Host 'Import common tasks'
Get-ChildItem -Path $BuildRoot\BuildTasks\*.Task.ps1 |
    ForEach-Object {Write-Host $_.FullName;. $_.FullName}
