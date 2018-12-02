# PowerLFM

PowerShell module to leverage the Last.fm API. This module is still a work in progress.
All the API documentation can be found [here](https://www.last.fm/api/intro).

## How to use PowerLFM

* Sign up for an account [here](https://www.last.fm/api/account/create) to receive an API key and shared secret for this module.

* These will be used to generate a token which will be used to create a session key.

```powershell
$session = Request-LFMToken -ApiKey $ApiKey -SharedSecret $SharedSecret | Request-LFMSession
```

* The contents of the $session variable are the session key and API key. Save this to the credential manager to use later.

```powershell
$session | Add-LFMConfiguration
```

* Alternatively, just pipe all the commands together

```powershell
Request-LFMToken -ApiKey $ApiKey -SharedSecret $SharedSecret | Request-LFMSession | Add-LFMConfiguration
```

* Make the configuration available in the current Powershell session.

```powershell
Get-LFMConfiguration
```

* Run a function from PowerLFM to test the configuration.

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

* [album.addTags](https://www.last.fm/api/show/album.addTags)
* [album.getInfo](https://www.last.fm/api/show/album.getInfo)
* [album.getTags](https;//www.last.fm/api/show/album.getTags)
* [album.getTopTags](https;//www.last.fm/api/show/album.getTopTags)
* [artist.addTags](https://www.last.fm/api/show/artist.addTags)
* [artist.getCorrection](https://www.last.fm/api/show/artist.getCorrection)
* [artist.getInfo](https://www.last.fm/api/show/artist.getInfo)
* [artist.getSimilar](https://www.last.fm/api/show/artist.getSimilar)
* [artist.getTags](https://www.last.fm/api/show/artist.getTags)
* [artist.getTopAlbums](https://www.last.fm/api/show/artist.getTopAlbums)
* [artist.getTopTags](https://www.last.fm/api/show/artist.getTopTags)
* [artist.getTopTracks](https://www.last.fm/api/show/artist.getTopTracks)
* [artist.removeTag](https://www.last.fm/api/show/artist.removeTag)
* [artist.search](https://www.last.fm/api/show/artist.search)
* [chart.getTopArtists](https://www.last.fm/api/show/chart.getTopArtists)
* [chart.getTopTags](https://www.last.fm/api/show/chart.getTopTags)
* [chart.getTopTracks](https://www.last.fm/api/show/chart.getTopTracks)
* [geo.getTopArtists](https://www.last.fm/api/show/geo.getTopArtists)
* [geo.getTopTracks](https://www.last.fm/api/show/geo.getTopTracks)
* [library.getArtists](https://www.last.fm/api/show/library.getArtists)
* [track.love](https://www.last.fm/api/show/track.love)
* [track.unlove](https://www.last.fm/api/show/track.unlove)
* [user.getArtistTracks](https://www.last.fm/api/show/user.getArtistTracks)
* [user.getFriends](https://www.last.fm/api/show/user.getFriends)
* [user.getInfo](https://www.last.fm/api/show/user.getInfo)
* [user.getLovedTracks](https://www.last.fm/api/show/user.getLovedTracks)
* [user.getTopAlbums](https://www.last.fm/api/show/user.getTopAlbums)
* [user.getTopArtists](https://www.last.fm/api/show/user.getTopArtists)
* [user.getTopTags](https://www.last.fm/api/show/user.getTopTags)
* [user.getTopTracks](https://www.last.fm/api/show/user.getTopTracks)
* [user.getWeeklyAlbumChart](https://www.last.fm/api/show/user.getWeeklyAlbumChart)
* [user.getWeeklyArtistChart](https://www.last.fm/api/show/user.get-WeeklyArtistChart)
* [user.getWeeklyChartList](https://www.last.fm/api/show/user.getWeeklyChartList)
* [user.getWeeklyTrackChart](https://www.last.fm/api/show/user.getWeeklyTrackChart)
