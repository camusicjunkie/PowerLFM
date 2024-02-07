# BeforeAll {
#     Remove-Module -Name PowerLFM -ErrorAction Ignore
#     Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1
# }


Describe 'Get-LFMUserLovedTrack: Unit' -Tag Unit {

    BeforeDiscovery {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMUserLovedTrack'.UserLovedTrack
    }

    BeforeAll {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMUserLovedTrack'.UserLovedTrack

        Mock Remove-CommonParameter {
            [hashtable] @{ }
        } -ModuleName 'PowerLFM'
        Mock ConvertTo-LFMParameter -ModuleName 'PowerLFM'
        Mock New-LFMApiQuery -ModuleName 'PowerLFM'
        Mock Invoke-LFMApiUri { $contextMock } -ModuleName 'PowerLFM'
        Mock ConvertFrom-UnixTime -ModuleName 'PowerLFM'
    }

    Context 'Input' {

        It 'Should throw when username is null' {
            { Get-LFMUserLovedTrack -UserName $null } | Should -Throw
        }
    }

    Context 'Execution' {

        BeforeAll {
            Get-LFMUserLovedTrack
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
            $output = Get-LFMUserLovedTrack
        }

        It "User first loved track should have a name of $($contextMock.LovedTracks.Track[0].Name)" {
            $output[0].Track | Should -Be $contextMock.LovedTracks.Track[0].Name
        }

        It "User first loved track should have artist name of $($contextMock.LovedTracks.Track[0].Artist.Name)" {
            $output[0].Artist | Should -Be $contextMock.LovedTracks.Track[0].Artist.Name
        }

        It "User first loved track should have track id with a value of $($contextMock.LovedTracks.Track[0].Mbid)" {
            $output[0].TrackId | Should -Be $contextMock.LovedTracks.Track[0].Mbid
        }

        It "User second loved track should have artist id with a value of $($contextMock.LovedTracks.Track[1].Artist.Mbid)" {
            $output[1].ArtistId | Should -Be $contextMock.LovedTracks.Track[1].Artist.Mbid
        }

        It "User second loved track should have artist url of $($contextMock.LovedTracks.Track[1].Artist.Url)" {
            $output[1].ArtistUrl | Should -Be $contextMock.LovedTracks.Track[1].Artist.Url
        }

        It "User second loved track should have track url of $($contextMock.LovedTracks.Track[1].Url)" {
            $output[1].TrackUrl | Should -Be $contextMock.LovedTracks.Track[1].Url
        }

        It 'User should have two loved tracks' {
            $output.Track | Should -HaveCount 2
        }

        It 'User should not have more than two loved tracks' {
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

            { Get-LFMUserLovedTrack } | Should -Throw 'Error'
        }
    }
}
