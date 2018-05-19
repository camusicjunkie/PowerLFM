#Get public and private function definition files.
$Public = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
$Private = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)

#Dot source the files
Foreach ($import in @($Public + $Private)) {
    Try {
        . $import.FullName
    }
    Catch {
        Write-Error -Message "Failed to import function $($import.FullName): $_"
    }
}

New-Variable -Name projectName -Value 'PowerLFM' -Visibility Private
New-Variable -Name baseUrl -Value 'https://ws.audioscrobbler.com/2.0' -Visibility Private

Export-ModuleMember -Function $Public.BaseName