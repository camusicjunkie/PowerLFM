function Get-Md5Hash {
    [CmdletBinding()]
    [OutputType('System.String')]
    param (
        [Parameter()]
        [string] $String
    )

    $md5 = [System.Security.Cryptography.MD5]::Create()

    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($String)
        ([System.BitConverter]::ToString($md5.ComputeHash($bytes))) -replace '-'
    }
    finally {
        $md5.Dispose()
    }
}
