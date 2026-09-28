function Convert-LFMScrobbleQueueVersion {
    [CmdletBinding()]
    [OutputType('System.Management.Automation.PSCustomObject')]
    param (
        [Parameter(Mandatory)]
        [psobject] $Queue,

        # Named by the caller rather than resolved here: this converts a queue in memory
        # and never touches the file, and the path is wanted only so a refusal can say
        # which queue it is refusing.
        [Parameter(Mandatory)]
        [string] $Path,

        # Both of these carry the module's own values in production. They are parameters
        # so the migration path can be exercised without a version bump: the table is
        # empty until the on-disk shape first changes, and by then the engine that walks
        # it needs to have been proven already.
        [Collections.IDictionary] $Migrations = $scrobbleQueueMigrations,

        [int] $TargetVersion = $scrobbleQueueVersion
    )

    # The null check stands on its own: $null -as [int] is 0, which would otherwise read
    # as a queue written before version 1 and go looking for a migration out of it.
    #
    # -as rather than a cast: a version of 'one' has to be refused, not thrown at with a
    # type error that names neither the file nor the value.
    $version = if ($null -ne $Queue.Version) { $Queue.Version -as [int] }
    if ($null -eq $version) {
        throw ($localizedData.errorScrobbleQueueVersion -f $Path, $Queue.Version)
    }

    # A queue from a newer module is not a migration problem and never will be: this
    # module cannot know what the shape became. Upgrading is the only way forward.
    if ($version -gt $TargetVersion) {
        throw ($localizedData.errorScrobbleQueueNewer -f $Path, $version, $TargetVersion)
    }

    while ($version -lt $TargetVersion) {
        $step = $Migrations[$version]
        if ($null -eq $step) {
            throw ($localizedData.errorScrobbleQueueNoMigration -f $Path, $version, $TargetVersion)
        }

        $next = $version + 1

        $failure = $null
        try {
            $migrated = & $step $Queue
        }
        catch {
            $failure = $_.Exception.Message
        }

        # A step that returns nothing has not migrated the queue, it has lost it. Reading
        # on would hand back an empty queue and the next write would make that permanent.
        if ($null -eq $failure -and $null -eq $migrated) {
            $failure = $localizedData.errorScrobbleQueueMigrationEmpty
        }

        if ($null -ne $failure) {
            throw ($localizedData.errorScrobbleQueueMigration -f $Path, $version, $next, $failure)
        }

        # The engine stamps the version, not the step: a step describes one shape change
        # and cannot be trusted to say which version it landed on.
        $Queue = [pscustomobject] @{
            Version   = $next
            Scrobbles = $migrated.Scrobbles
        }

        $version = $next
    }

    $Queue
}
