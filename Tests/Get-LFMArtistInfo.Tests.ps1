BeforeAll {
    Remove-Module -Name PowerLFM -ErrorAction Ignore
    Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1
}

Describe 'Get-LFMArtistInfo: Unit' -Tag Unit {

    BeforeDiscovery {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMArtistInfo'.ArtistInfo
    }

    BeforeAll {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMArtistInfo'.ArtistInfo

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
            { Get-LFMArtistInfo -Artist $null } | Should -Throw
        }
    }

    Context 'Execution' {

        BeforeAll {
            Get-LFMArtistInfo -Artist Artist
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
            $output = Get-LFMArtistInfo -Artist Artist
        }

        It "Artist should have artist name of $($contextMock.Artist.Name)" {
            $output.Artist | Should -Be $contextMock.Artist.Name
        }

        It "Artist should have id of $($contextMock.Artist.Mbid)" {
            $output.Id | Should -Be $contextMock.Artist.Mbid
        }

        It "Artist should have url of $($contextMock.Artist.Url)" {
            $output.Url | Should -Be $contextMock.Artist.Url
        }

        It "Artist should have listeners with a value of $($contextMock.Artist.Stats.Listeners)" {
            $output.Listeners | Should -BeOfType [int]
            $output.Listeners | Should -Be $contextMock.Artist.Stats.Listeners
        }

        It "Artist should have playcount with a value of $($contextMock.Artist.Stats.PlayCount)" {
            $output.PlayCount | Should -BeOfType [int]
            $output.PlayCount | Should -Be $contextMock.Artist.Stats.PlayCount
        }

        It "Artist first similar artist should have name of $($contextMock.Artist.Similar.Artist[0].Name)" {
            $output.SimilarArtists[0].Artist | Should -Be $contextMock.Artist.Similar.Artist[0].Name
        }

        It "Artist second similar artist should have url of $($contextMock.Artist.Similar.Artist[1].Url)" {
            $output.SimilarArtists[1].Url | Should -Be $contextMock.Artist.Similar.Artist[1].Url
        }

        It 'Artist should have two similar artists' {
            $output.SimilarArtists | Should -HaveCount 2
        }

        It 'Artist should not have more than two similar artists' {
            $output.SimilarArtists | Should -Not -BeNullOrEmpty
            $output.SimilarArtists | Should -Not -HaveCount 3
        }

        It "Artist first tag should have name of $($contextMock.Artist.Tags.Tag[0].Name)" {
            $output.Tags[0].Tag | Should -Be $contextMock.Artist.Tags.Tag[0].Name
        }

        It "Artist second tag should have url of $($contextMock.Artist.Tags.Tag[1].Url)" {
            $output.Tags[1].Url | Should -Be $contextMock.Artist.Tags.Tag[1].Url
        }

        It 'Artist should have two tags' {
            $output.Tags | Should -HaveCount 2
        }

        It 'Artist should not have more than two tags' {
            $output.Tags | Should -Not -HaveCount 3
        }

        It "Artist should have summary of '$($contextMock.Artist.Bio.Summary)'" {
            $output.Summary | Should -BeExactly $contextMock.Artist.Bio.Summary
        }

        It "Artist should have a user play count of $($contextMock.Artist.Stats.UserPlayCount)" {
            $output = Get-LFMArtistInfo -Artist Artist -UserName camusicjunkie
            $output.UserPlayCount | Should -Be $contextMock.Artist.Stats.UserPlayCount
        }

        It 'Artist should have two similar artists when id parameter is used' {
            $output = Get-LFMArtistInfo -Id (New-Guid)
            $output.SimilarArtists | Should -HaveCount 2
        }

        It 'Should call the correct Last.fm get method' {
            Get-LFMArtistInfo -Artist Artist

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

            { Get-LFMArtistInfo -Artist Artist } | Should -Throw 'Error'
        }
    }
}
