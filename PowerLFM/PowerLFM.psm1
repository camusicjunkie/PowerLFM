#Get public and private function definition files.
$Public  = Get-ChildItem $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue
$Private = Get-ChildItem $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue

#Dot source the files
foreach($import in @($Public + $Private)) {
    try {
        . $import.fullname
    }
    catch {
        Write-Error "Failed to import function $($import.fullname)"
    }
}

#Create some aliases, export public functions and the SecretServerConfig variable
$PublicNames = $Public | Select-Object -ExpandProperty BaseName

Export-ModuleMember -Function $PublicNames