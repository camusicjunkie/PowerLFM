# BeforeAll {
#     Remove-Module -Name PowerLFM -ErrorAction Ignore
#     Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1
# }


Describe 'Get-LFMUserWeeklyAlbumChart: Unit' -Tag Unit {

    BeforeAll {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMUserWeeklyAlbumChart'.UserWeeklyAlbumChart

        Mock Remove-CommonParameter {
            [hashtable] @{ }
        } -ModuleName 'PowerLFM'
        Mock ConvertTo-LFMParameter -ModuleName 'PowerLFM'
        Mock New-LFMApiQuery -ModuleName 'PowerLFM'
        Mock Invoke-LFMApiUri { $contextMock } -ModuleName 'PowerLFM'
    }

    Context 'Input' {

        It 'Should throw when username is null' {
            { Get-LFMUserWeeklyAlbumChart -UserName $null } | Should -Throw
        }
    }

    Context 'Execution' {

        BeforeAll {
            Get-LFMUserWeeklyAlbumChart
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
            $output = Get-LFMUserWeeklyAlbumChart
        }

        It 'Should return the correct first weekly album chart name' {
            $output[0].Album | Should -Be $contextMock.WeeklyAlbumChart.Album[0].Name
        }

        It 'Should return the correct first weekly album chart artist name' {
            $output[0].Artist | Should -Be $contextMock.WeeklyAlbumChart.Album[0].Artist.'#Text'
        }

        It 'Should return the correct first weekly album chart url' {
            $output[0].Url | Should -Be $contextMock.WeeklyAlbumChart.Album[0].Url
        }

        It 'Should return the correct second weekly album chart url' {
            $output[1].Url | Should -Be $contextMock.WeeklyAlbumChart.Album[1].Url
        }

        It 'Should return the correct second weekly album chart artist id' {
            $output[1].ArtistId | Should -Be $contextMock.WeeklyAlbumChart.Album[1].Artist.Mbid
        }

        It 'Should return the correct second weekly album chart play count' {
            $output[1].PlayCount | Should -Be $contextMock.WeeklyAlbumChart.Album[1].PlayCount
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

            { Get-LFMUserWeeklyAlbumChart } | Should -Throw 'Error'
        }
    }
}
