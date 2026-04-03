# PowerLFM

[![PowerShell Gallery Version](https://img.shields.io/powershellgallery/v/PowerLFM?style=flat-square)](https://www.powershellgallery.com/packages/PowerLFM) [![AppVeyor](https://img.shields.io/appveyor/ci/camusicjunkie/PowerLFM?style=flat-square)](https://ci.appveyor.com/project/camusicjunkie/powerlfm) [![GitHub](https://img.shields.io/github/license/camusicjunkie/PowerLFM?style=flat-square)](https://github.com/camusicjunkie/PowerLFM/blob/master/LICENSE)

PowerShell module to leverage the Last.fm API.

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
Get-LFMAlbumInfo -Artist Deftones -Album Gore
```

* Add command to a variable to inspect the nested objects further.

```powershell
$album = Get-LFMAlbumInfo -Artist Deftones -Album Gore
$album.Tracks
$album.Tags
```

## Currently unsupported methods

## Currently supported methods

* Album
  * [album.addTags](https://www.last.fm/api/show/album.addTags)
  * [album.getInfo](https://www.last.fm/api/show/album.getInfo)
  * [album.getTags](https://www.last.fm/api/show/album.getTags)
  * [album.getTopTags](https://www.last.fm/api/show/album.getTopTags)
  * [album.removeTag](https://www.last.fm/api/show/album.removeTag)
  * [album.search](https://www.last.fm/api/show/album.search)
* Artist
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
* Auth
  * [auth.getSession](https://www.last.fm/api/show/auth.getSession)
  * [auth.getToken](https://www.last.fm/api/show/auth.getToken)
* Chart
  * [chart.getTopArtists](https://www.last.fm/api/show/chart.getTopArtists)
  * [chart.getTopTags](https://www.last.fm/api/show/chart.getTopTags)
  * [chart.getTopTracks](https://www.last.fm/api/show/chart.getTopTracks)
* Geo
  * [geo.getTopArtists](https://www.last.fm/api/show/geo.getTopArtists)
  * [geo.getTopTracks](https://www.last.fm/api/show/geo.getTopTracks)
* Library
  * [library.getArtists](https://www.last.fm/api/show/library.getArtists)
* Tag
  * [tag.getInfo](https://www.last.fm/api/show/tag.getInfo)
  * [tag.getSimilar](https://www.last.fm/api/show/tag.getSimilar)
  * [tag.getTopAlbums](https://www.last.fm/api/show/tag.getTopAlbums)
  * [tag.getTopArtists](https://www.last.fm/api/show/tag.getTopArtists)
  * [tag.getTopTags](https://www.last.fm/api/show/tag.getTopTags)
  * [tag.getTopTracks](https://www.last.fm/api/show/tag.getTopTracks)
  * [tag.getWeeklyChartList](https://www.last.fm/api/show/tag.getWeeklyChartList)
* Track
  * [track.addTags](https://www.last.fm/api/show/track.addTags)
  * [track.getCorrection](https://www.last.fm/api/show/track.getCorrection)
  * [track.getInfo](https://www.last.fm/api/show/track.getInfo)
  * [track.getSimilar](https://www.last.fm/api/show/track.getSimilar)
  * [track.getTags](https://www.last.fm/api/show/track.getTags)
  * [track.getTopTags](https://www.last.fm/api/show/track.getTopTags)
  * [track.love](https://www.last.fm/api/show/track.love)
  * [track.removeTag](https://www.last.fm/api/show/track.removeTag)
  * [track.scrobble](https://www.last.fm/api/show/track.scrobble)
  * [track.search](https://www.last.fm/api/show/track.search)
  * [track.unlove](https://www.last.fm/api/show/track.unlove)
  * [track.updateNowPlaying](https://www.last.fm/api/show/track.updateNowPlaying)
* User
  * [user.getFriends](https://www.last.fm/api/show/user.getFriends)
  * [user.getInfo](https://www.last.fm/api/show/user.getInfo)
  * [user.getLovedTracks](https://www.last.fm/api/show/user.getLovedTracks)
  * [user.getPersonalTags](https://www.last.fm/api/show/user.getPersonalTags)
  * [user.getRecentTracks](https://www.last.fm/api/show/user.getRecentTracks)
  * [user.getTopAlbums](https://www.last.fm/api/show/user.getTopAlbums)
  * [user.getTopArtists](https://www.last.fm/api/show/user.getTopArtists)
  * [user.getTopTags](https://www.last.fm/api/show/user.getTopTags)
  * [user.getTopTracks](https://www.last.fm/api/show/user.getTopTracks)
  * user.getTrackScrobbles
  * [user.getWeeklyAlbumChart](https://www.last.fm/api/show/user.getWeeklyAlbumChart)
  * [user.getWeeklyArtistChart](https://www.last.fm/api/show/user.get-WeeklyArtistChart)
  * [user.getWeeklyChartList](https://www.last.fm/api/show/user.getWeeklyChartList)
  * [user.getWeeklyTrackChart](https://www.last.fm/api/show/user.getWeeklyTrackChart)
