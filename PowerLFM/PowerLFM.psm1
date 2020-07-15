#region Init
using namespace System.Management.Automation
Import-LocalizedData -BindingVariable localizedData -FileName localizedData
#endregion Init

#region Variables
New-Variable -Name module -Value 'PowerLFM'
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
        Write-Error -Message ($localizedData.errorFunctionImport -f $import.FullName)
    }
}
