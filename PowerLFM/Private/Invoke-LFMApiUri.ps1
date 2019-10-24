function Invoke-LFMApiUri {
    param (
        [uri] $Uri,

        [ValidateSet('Get', 'Post')]
        [string] $Method = 'Get'
    )

    try {
        $irm = Invoke-RestMethod -Method $Method -Uri $Uri -ErrorAction Stop

        if ($irm.Error) {
            throw $irm
        }

        Write-Output $irm
    }
    catch {
        $response = if ($null -ne $_.ErrorDetails) {
            $_.ErrorDetails.Message | ConvertFrom-Json
        }
        else {
            $_.TargetObject
        }

        $message = [char]::ToUpper($response.Message[0]) + $response.Message.Substring(1)
        throw "$message"
    }
}
