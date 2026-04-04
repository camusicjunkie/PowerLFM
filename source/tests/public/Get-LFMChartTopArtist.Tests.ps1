# BeforeAll {
#     Remove-Module -Name PowerLFM -ErrorAction Ignore
#     Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1
# }


Describe 'Get-LFMChartTopArtist: Unit' -Tag Unit {

    BeforeAll {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMChartTopArtist'.ChartTopArtist

        Mock Remove-CommonParameter {
            [hashtable] @{ }
        } -ModuleName 'PowerLFM'
        Mock ConvertTo-LFMParameter -ModuleName 'PowerLFM'
        Mock New-LFMApiQuery -ModuleName 'PowerLFM'
        Mock Invoke-LFMApiUri { $contextMock } -ModuleName 'PowerLFM'
    }

    Context 'Input' {

        It 'Should throw when limit is greater than 119' {
            { Get-LFMChartTopArtist -Limit 120 } | Should -Throw
        }
    }

    Context 'Execution' {

        BeforeAll {
            Get-LFMChartTopArtist
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
            $output = Get-LFMChartTopArtist
        }

        It 'Should return the correct first top artist name' {
            $output[0].Artist | Should -Be $contextMock.Artists.Artist[0].Name
        }

        It 'Should return the correct first top artist id' {
            $output[0].Id | Should -Be $contextMock.Artists.Artist[0].Mbid
        }

        It 'Should return the correct first top artist listener count' {
            $output[0].Listeners | Should -BeOfType [int]
            $output[0].Listeners | Should -Be $contextMock.Artists.Artist[0].Listeners
        }

        It 'Should return the correct second top artist listener count' {
            $output[1].Listeners | Should -BeOfType [int]
            $output[1].Listeners | Should -Be $contextMock.Artists.Artist[1].Listeners
        }

        It 'Should return the correct second top artist url' {
            $output[1].Url | Should -Be $contextMock.Artists.Artist[1].Url
        }

        It 'Should return the correct second top artist play count' {
            $output[1].PlayCount | Should -BeOfType [int]
            $output[1].PlayCount | Should -Be $contextMock.Artists.Artist[1].PlayCount
        }

        It 'Chart should have two top artists' {
            $output.Artist | Should -HaveCount 2
        }

        It 'Chart should not have more than two top artists' {
            $output.Artist | Should -Not -BeNullOrEmpty
            $output.Artist | Should -Not -HaveCount 3
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

            { Get-LFMChartTopArtist } | Should -Throw 'Error'
        }
    }
}
