# BeforeAll {
#     Remove-Module -Name PowerLFM -ErrorAction Ignore
#     Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1
# }


Describe 'Get-LFMArtistTopTrack: Unit' -Tag Unit {

    BeforeAll {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMArtistTopTrack'.ArtistTopTrack

        Mock Remove-CommonParameter {
            [hashtable] @{
                Artist = 'Artist'
            }
        } -ModuleName 'PowerLFM'
        Mock ConvertTo-LFMParameter -ModuleName 'PowerLFM'
        Mock New-LFMApiQuery -ModuleName 'PowerLFM'
        Mock Invoke-LFMApiUri { $contextMock } -ModuleName 'PowerLFM'
    }

    Context 'Input' {

        It 'Should throw when artist is null' {
            { Get-LFMArtistTopTrack -Artist $null } | Should -Throw
        }
    }

    Context 'Execution' {

        BeforeAll {
            Get-LFMArtistTopTrack -Artist Artist
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
            $output = Get-LFMArtistTopTrack -Artist Artist
        }

        It 'Should return the correct first top track name' {
            $output[0].Track | Should -Be $contextMock.Toptracks.Track[0].Name
        }

        It 'Should return the correct first top track id' {
            $output[0].Id | Should -Be $contextMock.Toptracks.Track[0].Mbid
        }

        It 'Should return the correct first top track listener count' {
            $output[0].Listeners | Should -BeOfType [int]
            $output[0].Listeners | Should -Be $contextMock.Toptracks.Track[0].Listeners
        }

        It 'Should return the correct second top track listener count' {
            $output[1].Listeners | Should -BeOfType [int]
            $output[1].Listeners | Should -Be $contextMock.Toptracks.Track[1].Listeners
        }

        It 'Should return the correct second top track url' {
            $output[1].Url | Should -Be $contextMock.Toptracks.Track[1].Url
        }

        It 'Should return the correct second top track play count' {
            $output[1].PlayCount | Should -BeOfType [int]
            $output[1].PlayCount | Should -Be $contextMock.Toptracks.Track[1].PlayCount
        }

        It 'Artist should have two top tracks' {
            $output.Album | Should -HaveCount 2
        }

        It 'Artist should not have more than two top tracks' {
            $output.Album | Should -Not -BeNullOrEmpty
            $output.Album | Should -Not -HaveCount 3
        }

        It 'Artist should have two top tracks when id parameter is used' {
            $output = Get-LFMArtistTopTrack -Id (New-Guid)
            $output.Track | Should -HaveCount 2
        }

        It 'Should call the correct Last.fm get method' {
            Get-LFMArtistTopTrack -Artist Artist

            $siParams = @{
                CommandName     = 'Invoke-LFMApiUri'
                ModuleName      = 'PowerLFM'
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

            { Get-LFMArtistTopTrack -Artist Artist } | Should -Throw 'Error'
        }
    }
}
