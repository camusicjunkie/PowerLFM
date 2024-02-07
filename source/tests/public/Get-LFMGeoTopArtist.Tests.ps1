# BeforeAll {
#     Remove-Module -Name PowerLFM -ErrorAction Ignore
#     Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1
# }


Describe 'Get-LFMGeoTopArtist: Unit' -Tag Unit {

    BeforeDiscovery {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMGeoTopArtist'.GeoTopArtist
    }

    BeforeAll {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMGeoTopArtist'.GeoTopArtist

        Mock Remove-CommonParameter {
            [hashtable] @{
                Country = 'Country'
            }
        } -ModuleName 'PowerLFM'
        Mock ConvertTo-LFMParameter -ModuleName 'PowerLFM'
        Mock New-LFMApiQuery -ModuleName 'PowerLFM'
        Mock Invoke-LFMApiUri { $contextMock } -ModuleName 'PowerLFM'
    }

    Context 'Input' {

        It 'Should throw when limit is greater than 119' {
            { Get-LFMGeoTopArtist -Country Country -Limit 120 } | Should -Throw
        }
    }

    Context 'Execution' {

        BeforeAll {
            Get-LFMGeoTopArtist -Country Country
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
            $output = Get-LFMGeoTopArtist -Country Country
        }

        It "Country first top artist should have name of $($contextMock.TopArtists.Artist[0].Name)" {
            $output[0].Artist | Should -Be $contextMock.TopArtists.Artist[0].Name
        }

        It "Country first top artist should have id of $($contextMock.TopArtists.Artist[0].Mbid)" {
            $output[0].Id | Should -Be $contextMock.TopArtists.Artist[0].Mbid
        }

        It "Country first top artist should have listeners with a value of $($contextMock.TopArtists.Artist[0].Listeners)" {
            $output[0].Listeners | Should -BeOfType [int]
            $output[0].Listeners | Should -Be $contextMock.TopArtists.Artist[0].Listeners
        }

        It "Country second top artist should have listeners with a value of $($contextMock.TopArtists.Artist[1].Listeners)" {
            $output[1].Listeners | Should -BeOfType [int]
            $output[1].Listeners | Should -Be $contextMock.TopArtists.Artist[1].Listeners
        }

        It "Country second top artist should have track url of $($contextMock.TopArtists.Artist[1].Url)" {
            $output[1].Url | Should -Be $contextMock.TopArtists.Artist[1].Url
        }

        It 'Country should have two top artists' {
            $output.Artist | Should -HaveCount 2
        }

        It 'Country should not have more than two top artists' {
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

            { Get-LFMGeoTopArtist -Country Country } | Should -Throw 'Error'
        }
    }
}
