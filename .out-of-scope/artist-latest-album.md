# Artist's Latest Album

PowerLFM does not provide a way to get an Artist's most recent release, and cannot
usefully provide one.

## Why this is out of scope

This isn't a design preference — the Last.fm API has no endpoint that answers the
question, and the closest approximation is wrong in exactly the case people want it for.

The nearest endpoint is `artist.getTopAlbums`, which PowerLFM exposes as
`Get-LFMArtistTopAlbum`. Its response carries no date of any kind:

```powershell
# Everything artist.getTopAlbums gives us:
[pscustomobject] @{
    'PSTypeName' = 'PowerLFM.Artist.Album'
    'Album'      = $album.Name
    'Id'         = $album.Mbid
    'Url'        = [uri] $album.Url
    'PlayCount'  = [int] $album.PlayCount
}
```

Results are ordered by popularity, and Last.fm documents no alternative sort and no date
filter. So finding a "latest" album would mean fetching the top albums, then calling
`album.getInfo` once per album to read a release date, then taking the maximum — an N+1
request pattern to compute a derived answer the service never offered.

Worse, it would be systematically wrong for the use case that motivates it. Requests for
this feature are about **discovering new releases**. A just-released album has no plays
yet, so it does not appear in top albums at all. The feature would reliably miss precisely
the albums it exists to find, while looking like it worked.

Last.fm is a service for *listening data* — plays, listeners, tags, charts. Release
catalog metadata is MusicBrainz's domain, and PowerLFM already surfaces the MusicBrainz ID
as `Id` on Artists, Albums and Tracks. A caller who needs release dates should follow that
`Id` into a MusicBrainz client, which can answer the question directly and correctly.

## Not covered by this rejection

Adding a `ReleaseDate` property to `Get-LFMAlbumInfo` for a *known* album is a separate,
much smaller question. Last.fm's docs advertise a `releasedate` field on `album.getInfo`,
though it is widely reported as empty in current JSON responses. That would need verifying
against a live call before anyone acts on it — and it still would not enable "latest
album", for the reasons above.

## Prior requests

- #125: "[Suggestion] add a $artist.latestalbum method"
