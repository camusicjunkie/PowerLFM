
Task Copy {
    "Creating Directory [$Destination]..."
    $null = New-Item -ItemType 'Directory' -Path $Destination -ErrorAction 'Ignore'

    $files = Get-ChildItem -Path $Source -File -Exclude '*.ps[dm]1'

    foreach ($file in $files) {
        'Creating [.{0}]...' -f $file.FullName.Replace($BuildRoot, '')
        Copy-Item -Path $file.FullName -Destination $Destination -Force
    }

    $directories = Get-ChildItem -Path $Source -Directory -Exclude $Folders

    foreach ($directory in $directories) {
        'Creating [.{0}]...' -f $directory.FullName.Replace($BuildRoot, '')
        Copy-Item -Path $directory.FullName -Destination $Destination -Recurse -Force
    }

    $license = Join-Path -Path $BuildRoot -ChildPath 'LICENSE'
    if ( Test-Path -Path $license -PathType Leaf ) {
        Copy-Item -Path $license -Destination $Destination
    }
}
