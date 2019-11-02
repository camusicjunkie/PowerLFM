function Invoke-LFMApiUri {
    [CmdletBinding()]
    param (
        [uri] $Uri,

        [ValidateSet('Get', 'Post')]
        [string] $Method = 'Get'
    )

    try {
        # If Invoke-RestMethod returns, say HTTP 403, it will cause a terminating
        # error and drop down in to the catch block. In most other cases if a bad
        # request is made it will actually return a JSON object with the error.
        $irm = Invoke-RestMethod -Method $Method -Uri $Uri -ErrorAction Stop

        # Api call could return an object with an error code as shown below. This
        # will account for that and throw the object down to the catch block.
        # error message         links
        # ----- -------         -----
        # 6     Album not found {}
        if ($irm.Error) {
            throw $irm
        }

        Write-Output $irm
    }
    catch {
        $response = if ($null -ne $_.ErrorDetails) {
            $_.ErrorDetails.Message | ConvertFrom-Json
            $errorId = 'PowerLFM.WebResponseException'
            $errorCategory = 'InvalidOperation'
        }
        else {
            $_.TargetObject
            $errorId = 'PowerLFM.ResourceNotFound'
            $errorCategory = 'ObjectNotFound'
        }

        # Constructing error message from response object.
        # Capitalizing first letter in sentence.
        $message = [char]::ToUpper($response.Message[0]) + $response.Message.Substring(1)
        if ($message -like 'Invalid API key*') {$message = $message + '. Run Get-LFMConfiguration.'}

        $PSCmdlet.ThrowTerminatingError([ErrorRecord]::new(
            $message,
            $errorId,
            $errorCategory,
            $MyInvocation.MyCommand.Name
        ))
    }
}
