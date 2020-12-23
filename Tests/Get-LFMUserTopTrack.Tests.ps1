BeforeAll {
    Remove-Module -Name PowerLFM -ErrorAction Ignore
    Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1
}

Describe 'Get-LFMUserTopTrack: Unit' -Tag Unit {

    BeforeDiscovery {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMUserTopTrack'.UserTopTrack
    }

    BeforeAll {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMUserTopTrack'.UserTopTrack

        Mock Remove-CommonParameter {
            [hashtable] @{ }
        } -ModuleName 'PowerLFM'
        Mock ConvertTo-LFMParameter -ModuleName 'PowerLFM'
        Mock New-LFMApiQuery -ModuleName 'PowerLFM'
        Mock Invoke-LFMApiUri { $contextMock } -ModuleName 'PowerLFM'
    }

    Context 'Input' {

        It 'Should throw when username is null' {
            { Get-LFMUserTopTrack -UserName $null } | Should -Throw
        }

        It 'Should throw when limit has a value of 51' {
            { Get-LFMUserTopTrack -Limit 51 } | Should -Throw
        }

        It 'Should not throw when limit has a value of 1 to 50' {
            { Get-LFMUserTopTrack -Limit 50 } | Should -Not -Throw
        }
    }

    Context 'Execution' {

        BeforeAll {
            Get-LFMUserTopTrack
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
            $output = Get-LFMUserTopTrack
        }

        It "User first top track should have track name of $($contextMock.TopTracks.Track[0].Name)" {
            $output[0].Track | Should -Be $contextMock.TopTracks.Track[0].Name
        }

        It "User first top track should have artist name of $($contextMock.TopTracks.Track[0].Artist.Name)" {
            $output[0].Artist | Should -Be $contextMock.TopTracks.Track[0].Artist.Name
        }

        It "User first top track should have playcount with a value of $($contextMock.TopTracks.Track[0].PlayCount)" {
            $output[0].PlayCount | Should -BeOfType [int]
            $output[0].PlayCount | Should -Be $contextMock.TopTracks.Track[0].PlayCount
        }

        It "User second top track should have playcount with a value of $($contextMock.TopTracks.Track[1].PlayCount)" {
            $output[1].PlayCount | Should -BeOfType [int]
            $output[1].PlayCount | Should -Be $contextMock.TopTracks.Track[1].PlayCount
        }

        It "User second top track should have artist id with a value of $($contextMock.TopTracks.Track[1].Artist.Mbid)" {
            $output[1].ArtistId | Should -Be $contextMock.TopTracks.Track[1].Artist.Mbid
        }

        It "User second top track should have artist url of $($contextMock.TopTracks.Track[1].Artist.Url)" {
            $output[1].ArtistUrl | Should -Be $contextMock.TopTracks.Track[1].Artist.Url
        }

        It "User second top track should have track url of $($contextMock.TopTracks.Track[1].Url)" {
            $output[1].TrackUrl | Should -Be $contextMock.TopTracks.Track[1].Url
        }

        It 'User should have two top tracks' {
            $output.Track | Should -HaveCount 2
        }

        It 'User should not have more than two top tracks' {
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
                    $Uri -like 'https://ws.audioscrobbler.com/2.0*'
                }
            }
            Should -Invoke @siParams
        }

        It 'Should throw when an error is returned in the response' {
            Mock Invoke-LFMApiUri { throw 'Error' } -ModuleName 'PowerLFM'

            { Get-LFMUserTopTrack } | Should -Throw 'Error'
        }
    }
}
