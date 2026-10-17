function Open-LFMBrowser {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [uri] $Url
    )

    $target = $Url.AbsoluteUri

    if ($IsMacOS) {
        Start-Process -FilePath 'open' -ArgumentList $target
    }
    elseif ($IsLinux) {
        Start-Process -FilePath 'xdg-open' -ArgumentList $target
    }
    else {
        Start-Process -FilePath $target
    }
}
