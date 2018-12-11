# Request-LFMToken

## SYNOPSIS
Requests a token from Last.fm.

## SYNTAX

```
Request-LFMToken [-ApiKey] <String> [-SharedSecret] <String> [<CommonParameters>]
```

## DESCRIPTION
Requests a token by sending the API key and API signature as arguments to the auth.getToken method call.

## EXAMPLES

### Example 1
```powershell
PS C:\> Request-LFMToken -ApiKey $apiKey -SharedSecret $sharedSecret
```

This will request a token using the API key and shared secret.

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
Accept pipeline input: False
Accept wildcard characters: False
```

### -SharedSecret
Shared secret that was created on Last.fm for a user and application. This is required for API calls that need to be signed.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.String

## NOTES

## RELATED LINKS

[https://www.last.fm/api/show/auth.getToken](https://www.last.fm/api/show/auth.getToken)

[https://www.last.fm/api/desktopauth](https://www.last.fm/api/desktopauth)
