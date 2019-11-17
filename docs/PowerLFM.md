---
Module Name: PowerLFM
Module Guid: c8d0461c-325b-4b14-bd9c-dd5fa57fafeb
Download Help Link: {{ Update Download Link }}
Help Version: {{ Please enter version of help manually (X.X.X.X) format }}
Locale: en-US
---

# PowerLFM Module
## Description
PowerShell module to leverage the Last.fm API. This module is still a work in progress. Breaking changes may be implemented without any prior notice.

## PowerLFM Cmdlets
### [Add-LFMAlbumTag](Add-LFMAlbumTag.md)
Tag an album using a list of user supplied tags.

### [Add-LFMArtistTag](Add-LFMArtistTag.md)
Tag an artist using a list of user supplied tags.

### [Add-LFMConfiguration](Add-LFMConfiguration.md)
Adds the token and keys to the credential manager.

### [Add-LFMTrackTag](Add-LFMTrackTag.md)
Tag a track using a list of user supplied tags.

### [Get-LFMAlbumInfo](Get-LFMAlbumInfo.md)
Get the metadata and tracklist for an album.

### [Get-LFMAlbumTag](Get-LFMAlbumTag.md)
Get the tags applied to an album.

### [Get-LFMAlbumTopTag](Get-LFMAlbumTopTag.md)
Get the top tags for an album.

### [Get-LFMArtistCorrection](Get-LFMArtistCorrection.md)
Check to see if a correction can be made.

### [Get-LFMArtistInfo](Get-LFMArtistInfo.md)
Get the metadata and biography for an artist.

### [Get-LFMArtistSimilar](Get-LFMArtistSimilar.md)
Get artists similar to another artist.

### [Get-LFMArtistTag](Get-LFMArtistTag.md)
Get the tags applied to an artist.

### [Get-LFMArtistTopAlbum](Get-LFMArtistTopAlbum.md)
Get the top albums for an artist.

### [Get-LFMArtistTopTag](Get-LFMArtistTopTag.md)
Get the top tags for an artist.

### [Get-LFMArtistTopTrack](Get-LFMArtistTopTrack.md)
Get the top tracks for an artist.

### [Get-LFMChartTopArtist](Get-LFMChartTopArtist.md)
Get the top artists chart.

### [Get-LFMChartTopTag](Get-LFMChartTopTag.md)
Get the top tags chart.

### [Get-LFMChartTopTrack](Get-LFMChartTopTrack.md)
Get the top tracks chart.

### [Get-LFMConfiguration](Get-LFMConfiguration.md)
Get the current configuration.

### [Get-LFMGeoTopArtist](Get-LFMGeoTopArtist.md)
Get the most popular artists by country.

### [Get-LFMGeoTopTrack](Get-LFMGeoTopTrack.md)
Get the most popular tracks by country and city.

### [Get-LFMLibraryArtist](Get-LFMLibraryArtist.md)
A paginated list of all the artists in a user's library, with play counts and tag counts.

### [Get-LFMTagInfo](Get-LFMTagInfo.md)
Get the metadata for a tag.

### [Get-LFMTagSimilar](Get-LFMTagSimilar.md)
Get tags similar to the one specified.

### [Get-LFMTagTopAlbum](Get-LFMTagTopAlbum.md)
Get the top albums tagged by this tag, ordered by tag count.

### [Get-LFMTagTopArtist](Get-LFMTagTopArtist.md)
Get the top artists tagged by this tag, ordered by tag count.

### [Get-LFMTagTopTag](Get-LFMTagTopTag.md)
Get the top tags, ordered by popularity.

### [Get-LFMTagTopTrack](Get-LFMTagTopTrack.md)
Get the top tracks tagged by this tag, ordered by tag count.

### [Get-LFMTagWeeklyChartList](Get-LFMTagWeeklyChartList.md)
Get a list of available charts for this tag, expressed as date ranges which can be sent to the chart services.

### [Get-LFMTrackCorrection](Get-LFMTrackCorrection.md)
Gets the supplied track and sees if there is a correction to a canonical track.

### [Get-LFMTrackInfo](Get-LFMTrackInfo.md)
Get the metadata for a track.

### [Get-LFMTrackSimilar](Get-LFMTrackSimilar.md)
Get tracks similar to another track.

### [Get-LFMTrackTag](Get-LFMTrackTag.md)
Get the tags applied to a track.

### [Get-LFMTrackTopTag](Get-LFMTrackTopTag.md)
Get the top tags for a track.

### [Get-LFMUserFriend](Get-LFMUserFriend.md)
Get a list of friends for a user.

### [Get-LFMUserInfo](Get-LFMUserInfo.md)
Get information about a user.

### [Get-LFMUserLovedTrack](Get-LFMUserLovedTrack.md)
Get the tracks loved by a user.

### [Get-LFMUserPersonalTag](Get-LFMUserPersonalTag.md)
Get a list of personal tags for a user.

### [Get-LFMUserRecentTrack](Get-LFMUserRecentTrack.md)
Get a list of the recent tracks listened to by a user.

### [Get-LFMUserTopAlbum](Get-LFMUserTopAlbum.md)
Get the top albums scrobbled by a user.

### [Get-LFMUserTopArtist](Get-LFMUserTopArtist.md)
Get the top artists scrobbled by a user.

### [Get-LFMUserTopTag](Get-LFMUserTopTag.md)
Get the top tags set by a user.

### [Get-LFMUserTopTrack](Get-LFMUserTopTrack.md)
Get the top tracks scrobbled by a user.

### [Get-LFMUserTrackScrobble](Get-LFMUserTrackScrobble.md)
Get all the times a track has been scrobbled by a user.

### [Get-LFMUserWeeklyAlbumChart](Get-LFMUserWeeklyAlbumChart.md)
Get an album chart for a user.

### [Get-LFMUserWeeklyArtistChart](Get-LFMUserWeeklyArtistChart.md)
Get an artist chart for a user.

### [Get-LFMUserWeeklyChartList](Get-LFMUserWeeklyChartList.md)
Get a list of available charts for a user.

### [Get-LFMUserWeeklyTrackChart](Get-LFMUserWeeklyTrackChart.md)
Get a track chart for a user.

### [Remove-LFMAlbumTag](Remove-LFMAlbumTag.md)
Untag an album using a user supplied tag.

### [Remove-LFMArtistTag](Remove-LFMArtistTag.md)
Untag an artist using a user supplied tag.

### [Remove-LFMConfiguration](Remove-LFMConfiguration.md)
Removes the current configuration.

### [Remove-LFMTrackTag](Remove-LFMTrackTag.md)
Untag an track using a user supplied tag.

### [Request-LFMSession](Request-LFMSession.md)
Request a session key from Last.fm.

### [Request-LFMToken](Request-LFMToken.md)
Requests a token from Last.fm.

### [Search-LFMAlbum](Search-LFMAlbum.md)
Search for an album by name.

### [Search-LFMArtist](Search-LFMArtist.md)
Search for an artist by name.

### [Search-LFMTrack](Search-LFMTrack.md)
Search for a track by name.

### [Set-LFMTrackLove](Set-LFMTrackLove.md)
Love a track for a user.

### [Set-LFMTrackNowPlaying](Set-LFMTrackNowPlaying.md)
{{ Fill in the Synopsis }}

### [Set-LFMTrackScrobble](Set-LFMTrackScrobble.md)
{{ Fill in the Synopsis }}

### [Set-LFMTrackUnlove](Set-LFMTrackUnlove.md)
Unlove a track for a user.

