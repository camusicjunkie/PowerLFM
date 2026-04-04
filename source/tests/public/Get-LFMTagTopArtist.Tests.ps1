# BeforeAll {
#     Remove-Module -Name PowerLFM -ErrorAction Ignore
#     Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1
# }


Describe 'Get-LFMTagTopArtist: Unit' -Tag Unit {

    BeforeAll {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMTagTopArtist'.TagTopArtist

        Mock Remove-CommonParameter {
            [hashtable] @{
                Tag = 'Tag'
            }
        } -ModuleName 'PowerLFM'
        Mock ConvertTo-LFMParameter -ModuleName 'PowerLFM'
        Mock New-LFMApiQuery -ModuleName 'PowerLFM'
        Mock Invoke-LFMApiUri { $contextMock } -ModuleName 'PowerLFM'
    }

    Context 'Input' {

        It 'Should throw when tag is null' {
            { Get-LFMTagTopArtist -Tag $null } | Should -Throw
        }
    }

    Context 'Execution' {

        BeforeAll {
            Get-LFMTagTopArtist -Tag Tag
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
            $output = Get-LFMTagTopArtist -Tag Tag
        }

        It 'Should return the correct first top artist name' {
            $output[0].Artist | Should -Be $contextMock.TopArtists.Artist[0].Name
        }

        It 'Should return the correct first top artist url' {
            $output[0].ArtistUrl | Should -Be $contextMock.TopArtists.Artist[0].Url
        }

        It 'Should return the correct first top artist rank' {
            $output[0].Rank | Should -Be $contextMock.TopArtists.Artist[0].'@attr'.Rank
        }

        It 'Should return the correct second top artist rank' {
            $output[1].Rank | Should -Be $contextMock.TopArtists.Artist[1].'@attr'.Rank
        }

        It 'Should return the correct second top artist id' {
            $output[1].ArtistId | Should -Be $contextMock.TopArtists.Artist[1].Mbid
        }

        It 'Should return the correct second top artist url' {
            $output[1].ArtistUrl | Should -Be $contextMock.TopArtists.Artist[1].Url
        }

        It 'Tag should have two top artists' {
            $output.Artist | Should -HaveCount 2
        }

        It 'Tag should not have more than two top artists' {
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

            { Get-LFMTagTopArtist -Tag Tag } | Should -Throw 'Error'
        }
    }
}
