
Describe 'Get-LFMAlbumTag: Unit' -Tag Unit {

    BeforeAll {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMAlbumTag'.AlbumTag

        Mock Remove-CommonParameter {
            [hashtable] @{
                Album  = 'Album'
                Artist = 'Artist'
            }
        } -ModuleName 'PowerLFM'
        Mock ConvertTo-LFMParameter -ModuleName 'PowerLFM'
        Mock New-LFMApiQuery -ModuleName 'PowerLFM'
        Mock Invoke-LFMApiUri { $contextMock } -ModuleName 'PowerLFM'
    }

    Context 'Input' {

        It 'Should throw when album is null' {
            { Get-LFMAlbumTag -Album $null } | Should -Throw
        }
    }

    Context 'Execution' {

        BeforeAll {
            Get-LFMAlbumTag -Album Album -Artist Artist
        }

        It 'Should remove common parameters from bound parameters' {
            $siParams = @{
                CommandName = 'Remove-CommonParameter'
                ModuleName  = 'PowerLFM'
                Scope       = 'Context'
                Exactly     = $true
                Times       = 1
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
            $output = Get-LFMAlbumTag -Album Album -Artist Artist
        }

        It 'Should return the correct first tag name' {
            $output[0].Tag | Should -Be $contextMock.Tags.Tag[0].Name
        }

        It 'Should return the correct second tag url' {
            $output[1].Url | Should -Be $contextMock.Tags.Tag[1].Url
        }

        It 'Album should have two tags' {
            $output.Tag | Should -HaveCount 2
        }

        It 'Album should have two tags when id parameter is used' {
            $output = Get-LFMAlbumTag -Id (New-Guid)
            $output.Tags | Should -HaveCount 2
        }

        It 'Should call the correct Last.fm get method' {
            Get-LFMAlbumTag -Album Album -Artist Artist

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

            { Get-LFMAlbumTag -Album Album -Artist Artist } | Should -Throw 'Error'
        }
    }
}
