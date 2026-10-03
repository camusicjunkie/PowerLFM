function Get-LFMSignature {
    [CmdletBinding()]
    [OutputType('System.String')]
    param (
        # The finished parameters, already under Last.fm's names.
        [Parameter(Mandatory)]
        [hashtable] $Parameter,

        [Parameter(Mandatory)]
        [string] $SharedSecret
    )

    # Ordinal, not culture-aware: Last.fm sorts parameter names bytewise, and a
    # batched scrobble's names carry brackets, which a culture-aware sort weights
    # differently from the server would.
    $names = [string[]] $Parameter.Keys
    [array]::Sort($names, [StringComparer]::Ordinal)

    $signed = -join $names.ForEach({ "$_$($Parameter[$_])" })
    Get-Md5Hash -String "$signed$SharedSecret"
}
