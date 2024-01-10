BeforeAll {
    Remove-Module -Name PowerLFM -ErrorAction Ignore
    Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1
}

Describe 'Get-LFMUserTrackScrobble: Unit' -Tag Unit {

    BeforeDiscovery {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMUserTrackScrobble'.UserTrackScrobble
    }

    BeforeAll {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMUserTrackScrobble'.UserTrackScrobble

        Mock Remove-CommonParameter {
            [hashtable] @{
                Track  = 'Track'
                Artist = 'Artist'
            }
        } -ModuleName 'PowerLFM'
        Mock ConvertTo-LFMParameter -ModuleName 'PowerLFM'
        Mock New-LFMApiQuery -ModuleName 'PowerLFM'
        Mock Invoke-LFMApiUri { $contextMock } -ModuleName 'PowerLFM'
        Mock ConvertFrom-UnixTime -ModuleName 'PowerLFM'
    }

    Context 'Input' {

        It 'Should throw when username is null' {
            { Get-LFMUserTrackScrobble -Track $null } | Should -Throw
        }

        It 'Should throw when limit has a value of 51' {
            { Get-LFMUserTrackScrobble -Track Track -Artist Artist -Limit 51 } | Should -Throw
        }

        It 'Should not throw when limit has a value of 1 to 50' {
            { Get-LFMUserTrackScrobble -Track Track -Artist Artist -Limit 50 } | Should -Not -Throw
        }
    }

    Context 'Execution' {

        BeforeAll {
            Get-LFMUserTrackScrobble -Track Track -Artist Artist
        }

        It 'Should remove common parameters from bound parameters' {
            $siParams = @{
                CommandName     = 'Remove-CommonParameter'
                ModuleName      = 'PowerLFM'
                Scope           = 'Context'
                Exactly         = $true
                Times           = 1
                ParameterFilter = {
                    $PSBoundParameters
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
    }

    Context 'Output' {

        BeforeAll {
            $output = Get-LFMUserTrackScrobble -Track Track -Artist Artist
        }

        It "User first scrobbled track should have a name of $($contextMock.TrackScrobbles.Track[0].Name)" {
            $output[0].Track | Should -Be $contextMock.TrackScrobbles.Track[0].Name
        }

        It "User first scrobbled track should have artist name of $($contextMock.TrackScrobbles.Track[0].Artist.'#text')" {
            $output[0].Artist | Should -Be $contextMock.TrackScrobbles.Track[0].Artist.'#text'
        }

        It "User first scrobbled track should have track id with a value of $($contextMock.TrackScrobbles.Track[0].Mbid)" {
            $output[0].TrackId | Should -Be $contextMock.TrackScrobbles.Track[0].Mbid
        }

        It "User second scrobbled track should have track url of $($contextMock.TrackScrobbles.Track[1].Url)" {
            $output[1].TrackUrl | Should -Be $contextMock.TrackScrobbles.Track[1].Url
        }

        It "User second scrobbled track should have artist name of $($contextMock.TrackScrobbles.Track[1].Album.'#text')" {
            $output[1].Album | Should -Be $contextMock.TrackScrobbles.Track[1].Album.'#text'
        }

        It 'User should have two scrobbled tracks' {
            $output.Track | Should -HaveCount 2
        }

        It 'User should not have more than two scrobbled tracks' {
            $output.Track | Should -Not -BeNullOrEmpty
            $output.Track | Should -Not -HaveCount 3
        }

        It 'Should call the correct Last.fm get method' {
            $siParams = @{
                CommandName     = 'Invoke-LFMApiUri'
                ModuleName      = 'PowerLFM'
                Scope           = 'Context'
                Exactly         = $true
                Times           = 1
                ParameterFilter = {
                    $Uri -like "$baseUrl*"
                }
            }
            Should -Invoke @siParams
        }

        It 'Should convert the date from unix time to the local time' {
            $siParams = @{
                CommandName     = 'ConvertFrom-UnixTime'
                ModuleName      = 'PowerLFM'
                Scope           = 'Context'
                Exactly         = $true
                Times           = 2
                ParameterFilter = {
                    $UnixTime -eq 0 -or
                    $UnixTime -eq 60 -and
                    $Local -eq $true
                }
            }
            Should -Invoke @siParams
        }

        It 'Should throw when an error is returned in the response' {
            Mock Invoke-LFMApiUri { throw 'Error' } -ModuleName 'PowerLFM'

            { Get-LFMUserTrackScrobble -Track Track -Artist Artist } | Should -Throw 'Error'
        }
    }
}
