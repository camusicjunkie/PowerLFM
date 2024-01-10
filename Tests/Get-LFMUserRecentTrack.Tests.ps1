BeforeAll {
    Remove-Module -Name PowerLFM -ErrorAction Ignore
    Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1
}

Describe 'Get-LFMUserRecentTrack: Unit' -Tag Unit {

    BeforeDiscovery {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMUserRecentTrack'.UserRecentTrack
    }

    BeforeAll {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMUserRecentTrack'.UserRecentTrack

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
            { Get-LFMUserRecentTrack -UserName $null } | Should -Throw
        }

        It 'Should throw when limit has a value of 51' {
            $gurtParams = @{
                UserName = 'UserName'
                Limit    = 51
            }
            { Get-LFMUserRecentTrack @gurtParams } | Should -Throw
        }

        It 'Should not throw when limit has a value of 1 to 50' {
            $gurtParams = @{
                UserName = 'UserName'
                Limit    = 50
            }
            { Get-LFMUserRecentTrack @gurtParams } | Should -Not -Throw
        }
    }

    Context 'Execution' {

        BeforeAll {
            Get-LFMUserRecentTrack
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
            $output = Get-LFMUserRecentTrack
        }

        It 'User first recent track should be playing now' {
            $output[0].ScrobbleTime | Should -Be 'Now Playing'
        }

        It "User first recent track should have a name of $($contextMock.RecentTracks.Track[0].Name)" {
            $output[0].Track | Should -Be $contextMock.RecentTracks.Track[0].Name
        }

        It "User first recent track should have an artist name of $($contextMock.RecentTracks.Track[0].Artist.Name)" {
            $output[0].Artist | Should -Be $contextMock.RecentTracks.Track[0].Artist.Name
        }

        It "User second recent track should have an album name of $($contextMock.RecentTracks.Track[1].Album.'#Text')" {
            $output[1].Album | Should -Be $contextMock.RecentTracks.Track[1].Album.'#Text'
        }

        It 'User second recent track should be loved' {
            $output[1].Loved | Should -Be 'Yes'
        }

        It "User third recent track should have an artist name of $($contextMock.RecentTracks.Track[2].Artist.Name)" {
            $output[2].Artist | Should -Be $contextMock.RecentTracks.Track[2].Artist.Name
        }

        It 'User should have two recent tracks' {
            $output | Should -HaveCount 2
        }

        It 'User should not have more than two recent tracks' {
            $output | Should -Not -BeNullOrEmpty
            $output | Should -Not -HaveCount 3
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

            { Get-LFMUserRecentTrack } | Should -Throw 'Error'
        }
    }
}
