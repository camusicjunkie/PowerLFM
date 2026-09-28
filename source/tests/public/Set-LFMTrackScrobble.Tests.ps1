
Describe 'Set-LFMTrackScrobble: Unit' -Tag Unit {

    BeforeAll {
        $script:dateTime = New-MockObject -Type 'datetime'

        Mock Remove-CommonParameter {
            [hashtable] @{
                Artist    = 'Artist'
                Track     = 'Track'
                Timestamp = $dateTime
            }
        } -ModuleName 'PowerLFM'
        Mock ConvertTo-LFMParameter -ModuleName 'PowerLFM'
        Mock Get-LFMSignature -ModuleName 'PowerLFM'
        Mock New-LFMApiQuery -ModuleName 'PowerLFM'
        Mock Invoke-LFMApiUri -ModuleName 'PowerLFM'
        Mock Get-LFMIgnoredMessage { @{ Code = 0 } } -ModuleName 'PowerLFM'
        Mock Send-LFMScrobbleQueue -ModuleName 'PowerLFM'
        Mock Add-LFMPendingScrobble -ModuleName 'PowerLFM'
    }

    Context 'Input' {
        It 'Should throw when artist is null' {
            { Set-LFMTrackScrobble -Artist $null } | Should -Throw
        }

        It 'Should throw when track is null' {
            { Set-LFMTrackScrobble -Track $null } | Should -Throw
        }
    }

    Context 'Execution' {

        BeforeAll {
            Set-LFMTrackScrobble -Artist Artist -Track Track -Timestamp $dateTime
        }

        It 'Should remove common parameters from bound parameters' {
            $siParams = @{
                CommandName = 'Remove-CommonParameter'
                ModuleName  = 'PowerLFM'
                Scope       = 'Context'
                Exactly     = $true
                Times       = 1
            }
            Should -Invoke @siParams
        }

        It 'Should create a signature from the parameters passed in' {
            $siParams = @{
                CommandName     = 'Get-LFMSignature'
                ModuleName      = 'PowerLFM'
                Scope           = 'Context'
                Exactly         = $true
                Times           = 1
                ParameterFilter = {
                    $Artist -eq 'Artist' -and
                    $Track -eq 'Track' -and
                    $Timestamp -eq $dateTime -and
                    $Method -eq 'track.scrobble'
                }
            }
            Should -Invoke @siParams
        }

        It 'Should convert parameters to format API expects after signing' {
            $siParams = @{
                CommandName = 'ConvertTo-LFMParameter'
                ModuleName  = 'PowerLFM'
                Scope       = 'Context'
                Exactly     = $true
                Times       = 1
            }
            Should -Invoke @siParams
        }

        It 'Should take hashtable and build a query for a uri' {
            $siParams = @{
                CommandName = 'New-LFMApiQuery'
                ModuleName  = 'PowerLFM'
                Scope       = 'Context'
                Exactly     = $true
                Times       = 1
            }
            Should -Invoke @siParams
        }

        It 'Should check to see if the response has not been filtered' {
            $siParams = @{
                CommandName     = 'Get-LFMIgnoredMessage'
                ModuleName      = 'PowerLFM'
                Scope           = 'Context'
                Exactly         = $true
                Times           = 1
                ParameterFilter = {
                    $Code -eq 0
                }
            }
            Should -Invoke @siParams
        }
    }

    Context 'Output' {

        It 'Should send proper output when -Whatif is used' {
            $output = Set-LFMTrackScrobble -Artist Artist -Track Track -Timestamp $dateTime -Verbose 4>&1
            $output | Should -Match 'Performing the operation "Setting track to now playing" on target "Track: Track".'
        }

        It 'Should output an object when -PassThru is used' {
            Mock Invoke-LFMApiUri { $contextMock } -ModuleName 'PowerLFM'

            $output = Set-LFMTrackScrobble -Artist Artist -Track Track -Timestamp $dateTime -PassThru
            $output.Artist | Should -Be $contextMock.Scrobbles.Scrobble.Artist.'#text'
            $output.Album | Should -Be $contextMock.Scrobbles.Scrobble.Album.'#text'
            $output.Track | Should -Be $contextMock.Scrobbles.Scrobble.Track.'#text'
        }

        It 'Should throw when ignored message code is 1' {
            Mock Get-LFMIgnoredMessage { @{ Code = 1; Message = 'Filtered message' } } -ModuleName 'PowerLFM'

            { Set-LFMTrackScrobble -Artist Artist -Track Track -Timestamp $dateTime } | Should -Throw 'Request has been filtered because of bad meta data. Filtered message.'
        }

        It 'Should throw when an error is returned in the response' {
            Mock Invoke-LFMApiUri { throw 'Error' } -ModuleName 'PowerLFM'

            { Set-LFMTrackScrobble -Artist Artist -Track Track -Timestamp $dateTime } | Should -Throw 'Error'
        }
    }

    Context 'Scrobble queue' {

        BeforeAll {
            $script:networkError = [System.Management.Automation.ErrorRecord]::new(
                [Exception]::new('Last.fm could not be reached.'),
                'PowerLFM.NetworkUnavailable',
                'ConnectionError',
                $null
            )
        }

        It 'Should attempt to flush the queue before submitting' {
            Set-LFMTrackScrobble -Artist Artist -Track Track -Timestamp $dateTime

            $siParams = @{
                CommandName = 'Send-LFMScrobbleQueue'
                ModuleName  = 'PowerLFM'
                Exactly     = $true
                Times       = 1
                Scope       = 'It'
            }
            Should -Invoke @siParams
        }

        It 'Should queue the scrobble when Last.fm could not be reached' {
            Mock Invoke-LFMApiUri { throw $networkError } -ModuleName 'PowerLFM'
            Mock Add-LFMPendingScrobble {
                [pscustomobject] @{ PSTypeName = 'PowerLFM.Track.PendingScrobble'; Track = 'Track' }
            } -ModuleName 'PowerLFM'

            Set-LFMTrackScrobble -Artist Artist -Track Track -Timestamp $dateTime

            $siParams = @{
                CommandName     = 'Add-LFMPendingScrobble'
                ModuleName      = 'PowerLFM'
                Exactly         = $true
                Times           = 1
                Scope           = 'It'
                ParameterFilter = {
                    $Artist -eq 'Artist' -and
                    $Track -eq 'Track' -and
                    $Timestamp -eq $dateTime
                }
            }
            Should -Invoke @siParams
        }

        It 'Should output a pending scrobble when queued with -PassThru' {
            Mock Invoke-LFMApiUri { throw $networkError } -ModuleName 'PowerLFM'
            Mock Add-LFMPendingScrobble {
                [pscustomobject] @{ PSTypeName = 'PowerLFM.Track.PendingScrobble'; Track = 'Track' }
            } -ModuleName 'PowerLFM'

            $output = Set-LFMTrackScrobble -Artist Artist -Track Track -Timestamp $dateTime -PassThru

            $output.PSTypeNames | Should -Contain 'PowerLFM.Track.PendingScrobble'
        }

        It 'Should not queue the scrobble when Last.fm returned an error' {
            Mock Invoke-LFMApiUri { throw 'Error' } -ModuleName 'PowerLFM'

            { Set-LFMTrackScrobble -Artist Artist -Track Track -Timestamp $dateTime } | Should -Throw

            $siParams = @{
                CommandName = 'Add-LFMPendingScrobble'
                ModuleName  = 'PowerLFM'
                Exactly     = $true
                Times       = 0
                Scope       = 'It'
            }
            Should -Invoke @siParams
        }

        It 'Should throw the original failure when the scrobble could not be queued' {
            Mock Invoke-LFMApiUri { throw $networkError } -ModuleName 'PowerLFM'
            Mock Add-LFMPendingScrobble { } -ModuleName 'PowerLFM'

            { Set-LFMTrackScrobble -Artist Artist -Track Track -Timestamp $dateTime } |
                Should -Throw 'Last.fm could not be reached.'
        }
    }
}
