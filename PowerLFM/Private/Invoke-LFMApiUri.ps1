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
            if ($_.ErrorDetails.Message | Test-Json) {
                $_.ErrorDetails.Message | ConvertFrom-Json
            }
            else {
                $_.ErrorDetails.Message
            }
            $errorId = 'PowerLFM.WebResponseException'
            $errorCategory = 'InvalidOperation'
        }
        else {
            $_.TargetObject
            $errorId = 'PowerLFM.ResourceNotFound'
            $errorCategory = 'ObjectNotFound'
        }

        $messagePart1 = $script:localizedData.errorInvalidApiKey
        $messagePart2 = $script:localizedData.errorInvalidRequest

        # Constructing error message from response object.
        # Capitalizing first letter in sentence.
        $responseMessage = [char]::ToUpper($response.Message[0]) + $response.Message.Substring(1)

        if ($responseMessage -like 'Invalid API key*') {$errorMessage = $responseMessage + $messagePart1}
        else {$errorMessage = "$messagePart2 $responseMessage."}

        $PSCmdlet.ThrowTerminatingError([ErrorRecord]::new(
            $errorMessage,
            $errorId,
            $errorCategory,
            $MyInvocation.MyCommand.Name
        ))
    }
}
