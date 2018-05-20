# PowerLFM

PowerShell module to leverage the Last.fm API. This module is still a work in progress.
All the API documentation can be found [here](https://www.last.fm/api/intro).

## How to use PowerLFM

* Sign up for an account [here](https://www.last.fm/api/account/create) to receive an API key and shared secret for this module.

* These will be used to generate a token which will be used to create a session key.

```powershell
$session = Request-LFMToken -ApiKey $ApiKey -SharedSecret $SharedSecret | Request-LFMSession
```

* The contents of the $session variable are the session key and API key. Save this to the registry to use later.

```powershell
$session | Add-LFMConfiguration
```

* Alternatively, just string all the commands together

```powershell
Request-LFMToken -ApiKey $ApiKey -SharedSecret $SharedSecret | Request-LFMSession | Add-LFMConfiguration
```

* Make the configuration available in the current Powershell session.

```powershell
Get-LFMConfiguration
```

* Run a function from PowerLFM to test the configuration like.

```powershell
Get-LFMAlbumInfo -Artist Cher -Album Believe
```

* Add command to a variable to inspect the nested objects further.

```powershell
$album = Get-LFMAlbumInfo -Artist Cher -Album Believe
$album.Tracks
$album.Tags
```

## Currently supported methods

* album.getInfo
* artist.addTags
* artist.getCorrection
* artist.getInfo
* artist.getSimilar
* artist.getTags
* track.love