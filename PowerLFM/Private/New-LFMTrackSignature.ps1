function New-LFMTrackSignature {
    [CmdletBinding(SupportsShouldProcess,
                   ConfirmImpact = 'Medium')]
    [OutputType('System.String')]
    param (
        # Parameter help description
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('track.addTags','track.removeTag',
                     'track.love','track.unlove')]
        [string] $Method,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Artist,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Track
    )
    try {
        $sigParams = @{
            'method' = $Method
            'api_key' = $LFMConfig.ApiKey
            'sk' = $LFMConfig.SessionKey
            'artist' = $Artist
            'track' = $Track
        }
    
        $keyValues = $sigParams.GetEnumerator() | Sort-Object Name | ForEach-Object {
            "$($_.Key)$($_.Value)"
        }
    
        $string = $keyValues -join ''
    
        if ($PSCmdlet.ShouldProcess('Shared secret', 'Creating track signature')) {
            Get-Md5Hash -String "$string$($LFMConfig.SharedSecret)"
        }
        Write-Verbose "$string$($LFMConfig.SharedSecret)"
    }
    catch {
        Write-Error $_.Exception.Message
    }
}
