BeforeAll {
    Remove-Module -Name PowerLFM -ErrorAction Ignore
    Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1
}

Describe 'Get-LFMAlbumTag: Unit' -Tag Unit {

    BeforeDiscovery {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMAlbumTag'.AlbumTag
    }

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
            $amParams = @{
                CommandName     = 'Remove-CommonParameter'
                ModuleName      = 'PowerLFM'
                Scope           = 'Context'
                Exactly         = $true
                Times           = 1
                ParameterFilter = {
                    $PSBoundParameters
                }
            }
            Assert-MockCalled @amParams
        }

        It 'Should convert parameters to format API expects after signing' {
            $amParams = @{
                CommandName = 'ConvertTo-LFMParameter'
                ModuleName  = 'PowerLFM'
                Scope       = 'Context'
                Exactly     = $true
                Times       = 1
            }
            Assert-MockCalled @amParams
        }

        It 'Should take hashtable and build a query for a uri' {
            $amParams = @{
                CommandName = 'New-LFMApiQuery'
                ModuleName  = 'PowerLFM'
                Scope       = 'Context'
                Exactly     = $true
                Times       = 1
            }
            Assert-MockCalled @amParams
        }
    }

    Context 'Output' {

        BeforeAll {
            $output = Get-LFMAlbumTag -Album Album -Artist Artist
        }

        It "Album first tag should have name of $($contextMock.Tags.Tag[0].Name)" {
            $output[0].Tag | Should -Be $contextMock.Tags.Tag[0].Name
        }

        It "Album second tag should have url of $($contextMock.Tags.Tag[1].Url)" {
            $output[1].Url | Should -Be $contextMock.Tags.Tag[1].Url
        }

        It 'Album should have two tags' {
            $output.Tag | Should -HaveCount 2
        }

        It 'Album should not have more than two tags' {
            $output.Tag | Should -Not -BeNullOrEmpty
            $output.Tag | Should -Not -HaveCount 3
        }

        It 'Album should have two tags when id parameter is used' {
            $output = Get-LFMAlbumTag -Id (New-Guid)
            $output.Tags | Should -HaveCount 2
        }

        It 'Should call the correct Last.fm get method' {
            Get-LFMAlbumTag -Album Album -Artist Artist

            $amParams = @{
                CommandName     = 'Invoke-LFMApiUri'
                ModuleName      = 'PowerLFM'
                Exactly         = $true
                Times           = 1
                ParameterFilter = {
                    $Uri -like 'https://ws.audioscrobbler.com/2.0*'
                }
            }
            Assert-MockCalled @amParams
        }

        It 'Should throw when an error is returned in the response' {
            Mock Invoke-LFMApiUri { throw 'Error' } -ModuleName 'PowerLFM'

            { Get-LFMAlbumTag -Album Album -Artist Artist } | Should -Throw 'Error'
        }
    }
}
