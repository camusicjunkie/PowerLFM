function Invoke-LFMApiUri {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [uri] $Uri
    )

    try {
        $irm = Invoke-RestMethod -Uri $Uri -ErrorAction Stop

        if ($irm.Error) {
            [pscustomobject] @{
                'Error' = $irm.Error
                'Message' = [char]::ToUpper($irm.Message[0]) + $irm.Message.Substring(1)
            }
        }
        else {
            Write-Output $irm
        }
    }
    catch {
        $response = $_.ErrorDetails.Message | ConvertFrom-Json

        [pscustomobject] @{
            'Error' = $response.Error
            'Message' = [char]::ToUpper($response.Message[0]) + $response.Message.Substring(1)
        }
    }
}
