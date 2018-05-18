# PowerLFM
PowerShell module to leverage the Last.fm API. This module is still a work in progress.
All the API documentation can be found [here](https://www.last.fm/api/intro).

## How to use PowerLFM
1. Sign up for an account [here](https://www.last.fm/api/account/create) to receive an API key and shared secret for this module.

2. These will be used to generate a token which will be used to create a session key.

	`$session = Request-LFMToken -ApiKey $ApiKey -SharedSecret $SharedSecret | Request-LFMSession`
			
3. The contents of the $session variable are the session key and API key. Save this to the registry to use later.
	
	`$session | Add-LFMConfiguration` or `Add-LFMConfiguration -APIKey $APIKey -SessionKey $session.SessionKey`
			
4. Alternatively, just string all the commands together
	
	`Request-LFMToken -ApiKey $ApiKey -SharedSecret $SharedSecret | Request-LFMSession | Add-LFMConfiguration`
			
5. Make the configuration available in the current Powershell session.
	
	`Get-LFMConfiguration`
	
6. Run a function from PowerLFM to test the configuration like `Get-LFMAlbumInfo -Album Believe -Artist Cher`
