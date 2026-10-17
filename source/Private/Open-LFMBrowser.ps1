function Open-LFMBrowser {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [uri] $Url
    )

    Start-Process -FilePath $Url.AbsoluteUri
}
