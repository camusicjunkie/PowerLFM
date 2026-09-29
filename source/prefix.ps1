using namespace System.Management.Automation
Import-LocalizedData -BindingVariable localizedData -FileName localizedData

New-Variable -Name baseUrl -Value 'https://ws.audioscrobbler.com/2.0'
New-Variable -Name scrobbleQueueVersion -Value 1

# Keyed by the version each step migrates away from: the step at key N takes the queue as
# version N wrote it and returns it in the shape version N+1 expects. Only Scrobbles is
# read back off what a step returns; Convert-LFMScrobbleQueueVersion stamps the version.
# Empty because the on-disk shape has not changed yet. Changing it means bumping
# scrobbleQueueVersion and adding the step that gets the old queues here.
#
# A plain hashtable, never [ordered]: an ordered dictionary indexes an integer by position
# rather than by key, so looking up the step for version 1 would quietly run the second
# step in the table. The versions are walked in order regardless of how they are stored.
New-Variable -Name scrobbleQueueMigrations -Value @{ }
# The one comparer for a Scrobble Identity. Ordinal, because a culture-sensitive comparison
# reads some strings as equal that this one does not and the two halves of the Scrobble Queue
# have to agree; case-insensitive, because Last.fm reads 'opeth' and 'Opeth' as one Artist.
# Held here rather than spelled out at each comparison site for the reason ADR-0005 gives for
# Update-LFMScrobbleQueue: a rule two callers are trusted to keep is a convention, and this
# one being kept in two ways is what let the queue refuse a Scrobble the Flush would have
# accounted for separately.
New-Variable -Name scrobbleIdentityComparer -Value ([StringComparer]::OrdinalIgnoreCase)
New-Variable -Name scrobbleQueueBatchSize -Value 50
New-Variable -Name scrobbleQueueWarningThreshold -Value 1000
