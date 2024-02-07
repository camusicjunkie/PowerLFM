# BeforeAll {
#     Remove-Module -Name PowerLFM -ErrorAction Ignore
#     Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1
# }


Describe 'Get-LFMTrackTopTag: Unit' -Tag Unit {

    BeforeDiscovery {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMTrackTopTag'.TrackTopTag
    }

    BeforeAll {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMTrackTopTag'.TrackTopTag

        Mock Remove-CommonParameter {
            [hashtable] @{
                Track  = 'Track'
                Artist = 'Artist'
            }
        } -ModuleName 'PowerLFM'
        Mock ConvertTo-LFMParameter -ModuleName 'PowerLFM'
        Mock New-LFMApiQuery -ModuleName 'PowerLFM'
        Mock Invoke-LFMApiUri { $contextMock } -ModuleName 'PowerLFM'
    }

    Context 'Input' {

        It 'Should throw when track is null' {
            { Get-LFMTrackTopTag -Track $null } | Should -Throw
        }
    }

    Context 'Execution' {

        BeforeAll {
            Get-LFMTrackTopTag -Track Track -Artist Artist
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
            $output = Get-LFMTrackTopTag -Artist Artist -Track Track
        }

        It "Track first top tag should have name of $($contextMock.TopTags.Tag[0].Name)" {
            $output[0].Tag | Should -Be $contextMock.TopTags.Tag[0].Name
        }

        It "Track second tag should have url of $($contextMock.TopTags.Tag[1].Url)" {
            $output[1].Url | Should -Be $contextMock.TopTags.Tag[1].Url
        }

        It "Track first tag should have match of $($contextMock.TopTags.Tag[0].Count)" {
            $output[0].Match | Should -Be $contextMock.TopTags.Tag[0].Count
        }

        It "Track second tag should have match of $($contextMock.TopTags.Tag[1].Count)" {
            $output[1].Match | Should -Be $contextMock.TopTags.Tag[1].Count
        }

        It 'Track should have two tags' {
            $output.Tag | Should -HaveCount 2
        }

        It 'Track should not have more than two tags' {
            $output.Tag | Should -Not -BeNullOrEmpty
            $output.Tag | Should -Not -HaveCount 3
        }

        It 'Track should have two tags when id parameter is used' {
            $output = Get-LFMTrackTopTag -Id (New-Guid)
            $output.Tag | Should -HaveCount 2
        }

        It 'Should call the correct Last.fm get method' {
            Get-LFMTrackTopTag -Track Track -Artist Artist

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

            { Get-LFMTrackTopTag -Track Track -Artist Artist } | Should -Throw 'Error'
        }
    }
}
