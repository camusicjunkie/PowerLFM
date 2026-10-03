function Get-LFMSessionKeyFingerprint {
    [CmdletBinding()]
    [OutputType('System.String')]
    param ()

    # The queue outlives the session that wrote it, so each Pending Scrobble records
    # which user's Session Key captured it. The hash, never the key itself.
    if ([string]::IsNullOrWhiteSpace($script:LFMConfig.SessionKey)) {
        # throw rather than ThrowTerminatingError: a caller with no try has to stop too.
        throw ([ErrorRecord]::new(
            [InvalidOperationException]::new($localizedData.errorConfigurationNotLoaded),
            'PowerLFM.ConfigurationNotLoaded',
            'InvalidOperation',
            $null
        ))
    }

    Get-Md5Hash -String $script:LFMConfig.SessionKey
}
