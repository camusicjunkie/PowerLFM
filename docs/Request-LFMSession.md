# Request-LFMSession

## SYNOPSIS
Request a session key from Last.fm.

## SYNTAX

```
Request-LFMSession [-ApiKey] <String> [-Token] <String> [-SharedSecret] <String> [<CommonParameters>]
```

## DESCRIPTION
Request a session key by sending the API key, shared secret, and the authentication token as arguments to the auth.getSession method call.

## EXAMPLES

### Example 1
```powershell
PS C:\> Request-LFMToken -ApiKey $apiKey -SharedSecret $sharedSecret | Request-LFMSession
```

This will request a token and send all three properties down the pipeline to request a session.

### Example 2
```powershell
PS C:\> Request-LFMSession -ApiKey $apiKey -Token $token -SharedSecret $sharedSecret
```

This will request a session key after the token has already been requested and stored in a variable.

## PARAMETERS

### -ApiKey
API key that was created on Last.fm for a user and application. This is required for all API calls.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -SharedSecret
Shared secret that was created on Last.fm for a user and application. This is required for API calls that need to be signed.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Token
Token used to generate a session key. It is valid for only 60 minutes from the moment it is granted to a user.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

## OUTPUTS

### System.String

## NOTES

## RELATED LINKS

[https://www.last.fm/api/show/auth.getSession](https://www.last.fm/api/show/auth.getSession)

[https://www.last.fm/api/desktopauth](https://www.last.fm/api/desktopauth)
