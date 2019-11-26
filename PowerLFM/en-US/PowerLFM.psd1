ConvertFrom-StringData @'
    vaultCredPresent = There is already a value present for {0}, do you wish to update the value?
    codeNone = None (the request passed all filters)
    codeFilteredArtist = Filtered artist
    codeFilteredTrack = Filtered track
    codeTimestampTooFarPast = Timestamp too far in the past
    codeTimestampTooFarFuture = Timestamp too far in the future
    codeScrobblesExceeded = Max daily scrobbles exceeded
    errorFiltered = Request has been filtered because of bad meta data. {0}.
    errorFiltered2 = Request has been filtered because of bad meta data.
    errorPasswordCredentialObject = Could not create PasswordCredential object
    errorPasswordVaultClass = Could not create PasswordVault class
    errorCredentials = Could not retrieve credentials for {0}. Run Add-LFMConfiguration with proper keys.
    errorInvalidApiKey = . Run Get-LFMConfiguration if token and session key have already been requested.
    errorInvalidRequest = This is not a valid request.
    tagAdded = Tag: {0} has been added
    tagRemoved = Tag: {0} has been removed
    trackLoved = Track: {0} has been loved
    trackUnloved = Track: {0} has been unloved
    configInSession = LFMConfig is loaded in to the session
    tokenRequest = Requesting token from {0}
    tokenAuthorizing = Authorizing application with requested token on account
'@
