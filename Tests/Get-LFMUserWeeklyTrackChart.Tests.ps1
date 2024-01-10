BeforeAll {
    Remove-Module -Name PowerLFM -ErrorAction Ignore
    Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1
}

Describe 'Get-LFMUserWeeklyTrackChart: Unit' -Tag Unit {

    BeforeDiscovery {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMUserWeeklyTrackChart'.UserWeeklyTrackChart
    }

    BeforeAll {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMUserWeeklyTrackChart'.UserWeeklyTrackChart

        Mock Remove-CommonParameter {
            [hashtable] @{ }
        } -ModuleName 'PowerLFM'
        Mock ConvertTo-LFMParameter -ModuleName 'PowerLFM'
        Mock New-LFMApiQuery -ModuleName 'PowerLFM'
        Mock Invoke-LFMApiUri { $contextMock } -ModuleName 'PowerLFM'
    }

    Context 'Input' {

        It 'Should throw when username is null' {
            { Get-LFMUserWeeklyTrackChart -UserName $null } | Should -Throw
        }
    }

    Context 'Execution' {

        BeforeAll {
            Get-LFMUserWeeklyTrackChart
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
            $output = Get-LFMUserWeeklyTrackChart
        }

        It "User weekly track chart first track should have name of $($contextMock.WeeklyTrackChart.Track[0].Name)" {
            $output[0].Track | Should -Be $contextMock.WeeklyTrackChart.Track[0].Name
        }

        It "User weekly track chart first track should have name of $($contextMock.WeeklyTrackChart.Track[0].Mbid)" {
            $output[0].Id | Should -Be $contextMock.WeeklyTrackChart.Track[0].Mbid
        }

        It "User weekly track chart first track should have artist name of $($contextMock.WeeklyTrackChart.Track[0].Artist.'#Text')" {
            $output[0].Artist | Should -Be $contextMock.WeeklyTrackChart.Track[0].Artist.'#Text'
        }

        It "User weekly track chart first track should have url of $($contextMock.WeeklyTrackChart.Track[0].Url)" {
            $output[0].Url | Should -Be $contextMock.WeeklyTrackChart.Track[0].Url
        }

        It "User weekly track chart second track should have url of $($contextMock.WeeklyTrackChart.Track[1].Url)" {
            $output[1].Url | Should -Be $contextMock.WeeklyTrackChart.Track[1].Url
        }

        It "User weekly track chart second track should have artist id with a value of $($contextMock.WeeklyTrackChart.Track[1].Artist.Mbid)" {
            $output[1].ArtistId | Should -Be $contextMock.WeeklyTrackChart.Track[1].Artist.Mbid
        }

        It "User weekly track chart second track should have a playcount of $($contextMock.WeeklyTrackChart.Track[1].PlayCount)" {
            $output[1].PlayCount | Should -Be $contextMock.WeeklyTrackChart.Track[1].PlayCount
        }

        It 'User weekly album chart should have two albums' {
            $output.Album | Should -HaveCount 2
        }

        It 'User weekly album chart should not have more than two albums' {
            $output.Album | Should -Not -BeNullOrEmpty
            $output.Album | Should -Not -HaveCount 3
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

        It 'Should throw when an error is returned in the response' {
            Mock Invoke-LFMApiUri { throw 'Error' } -ModuleName 'PowerLFM'

            { Get-LFMUserWeeklyTrackChart } | Should -Throw 'Error'
        }
    }
}
