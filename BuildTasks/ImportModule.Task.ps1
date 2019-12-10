function ImportModule {
    param(
        [string] $Path,
        [switch] $PassThru
    )


    if (-not (Test-Path -Path $Path)) {
        "Cannot find [$Path]."
        Write-Error -Message "Could not find module manifest [$Path]"
    }
    else {
        $file = Get-Item $Path
        $name = $file.BaseName

        $loaded = Get-Module -Name $name -All -ErrorAction Ignore
        if ($loaded) {
            "Unloading Module [$name] from a previous import..."
            $loaded | Remove-Module -Force
        }

        "Importing Module [$name] from [$($file.FullName)]..."
        Import-Module -Name $file.FullName -Force -PassThru:$PassThru
    }
}

task ImportModule {
    ImportModule -Path $ManifestPath
}
