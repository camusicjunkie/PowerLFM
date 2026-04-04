# BeforeAll {
#     Remove-Module -Name PowerLFM -ErrorAction Ignore
#     Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1
# }


Describe 'Get-LFMArtistTopTag: Unit' -Tag Unit {

    BeforeAll {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMArtistTopTag'.ArtistTopTag

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
            { Get-LFMArtistTopTag -Artist $null } | Should -Throw
        }
    }

    Context 'Execution' {

        BeforeAll {
            Get-LFMArtistTopTag -Artist Artist
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
            $output = Get-LFMArtistTopTag -Artist Artist
        }

        It 'Should return the correct first top tag name' {
            $output[0].Tag | Should -Be $contextMock.TopTags.Tag[0].Name
        }

        It 'Should return the correct second tag url' {
            $output[1].Url | Should -Be $contextMock.TopTags.Tag[1].Url
        }

        It 'Should return the correct first tag match count' {
            $output[0].Match | Should -Be $contextMock.TopTags.Tag[0].Count
        }

        It 'Should return the correct second tag match count' {
            $output[1].Match | Should -Be $contextMock.TopTags.Tag[1].Count
        }

        It 'Artist should have two tags' {
            $output.Tag | Should -HaveCount 2
        }

        It 'Artist should not have more than two tags' {
            $output.Tag | Should -Not -BeNullOrEmpty
            $output.Tag | Should -Not -HaveCount 3
        }

        It 'Artist should have two tags when id parameter is used' {
            $output = Get-LFMArtistTopTag -Id (New-Guid)
            $output.Tag | Should -HaveCount 2
        }

        It 'Should call the correct Last.fm get method' {
            Get-LFMArtistTopTag -Artist Artist

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

            { Get-LFMArtistTopTag -Artist Artist } | Should -Throw 'Error'
        }
    }
}
