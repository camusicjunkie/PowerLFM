#region Init
using namespace System.Management.Automation
Import-Module "$PSScriptRoot\lib\Microsoft.PowerShell.SecretManagement"
#endregion Init

#region Variables
New-Variable -Name baseUrl -Value 'https://ws.audioscrobbler.com/2.0'
#endregion Variables

#Get public and private function definition files.
$public = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
$private = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)

#Dot source the files
foreach ($import in @($public + $private)) {
    try {
        . $import.FullName
    }
    catch {
        Write-Error -Message "Failed to import function $($import.FullName): $_"
    }
}
