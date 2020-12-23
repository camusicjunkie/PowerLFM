BeforeAll {
    Remove-Module -Name PowerLFM -ErrorAction Ignore
    Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1
}

Describe 'Get-LFMUserPersonalTag: Unit' -Tag Unit {

    BeforeDiscovery {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMUserPersonalTag'.UserPersonalTag
    }

    BeforeAll {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMUserPersonalTag'.UserPersonalTag

        Mock Remove-CommonParameter {
            [hashtable] @{
                Tag     = 'Tag'
                TagType = 'Artist'
            }
        } -ModuleName 'PowerLFM'
        Mock ConvertTo-LFMParameter -ModuleName 'PowerLFM'
        Mock New-LFMApiQuery -ModuleName 'PowerLFM'
        Mock Invoke-LFMApiUri { $contextMock } -ModuleName 'PowerLFM'
    }

    Context 'Input' {

        It 'Should throw when username is null' {
            { Get-LFMUserPersonalTag -UserName $null } | Should -Throw
        }

        It 'Should throw when limit has a value of 51' {
            $guptParams = @{
                UserName = 'UserName'
                Tag      = 'Tag'
                TagType  = 'Artist'
                Limit    = 51
            }
            { Get-LFMUserPersonalTag @guptParams } | Should -Throw
        }

        It 'Should not throw when limit has a value of 1 to 50' {
            $guptParams = @{
                UserName = 'UserName'
                Tag      = 'Tag'
                TagType  = 'Album'
                Limit    = 50
            }
            { Get-LFMUserPersonalTag @guptParams } | Should -Not -Throw
        }
    }

    Context 'Execution' {

        BeforeAll {
            Get-LFMUserPersonalTag -Tag Tag -TagType Artist
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
            $output = Get-LFMUserPersonalTag -Tag Tag -TagType Artist
        }

        It "User first personal tag artist should have a name of $($contextMock.Taggings.Artists.Artist[0].Name)" {
            $output[0].Artist | Should -Be $contextMock.Taggings.Artists.Artist[0].Name
        }

        It "User first personal tag artist should have an id of $($contextMock.Taggings.Artists.Artist[0].Mbid)" {
            $output[0].Id | Should -Be $contextMock.Taggings.Artists.Artist[0].Mbid
        }

        It "User second personal tag artist should have a url of $($contextMock.Taggings.Artists.Artist[1].Url)" {
            $output[1].Url | Should -Be $contextMock.Taggings.Artists.Artist[1].Url
        }

        It 'User should have two personal tag artists' {
            $output.UserName | Should -HaveCount 2
        }

        It 'User should not have more than two personal tag artists' {
            $output.UserName | Should -Not -BeNullOrEmpty
            $output.UserName | Should -Not -HaveCount 3
        }

        It 'Should call the correct Last.fm get method' {
            $siParams = @{
                CommandName     = 'Invoke-LFMApiUri'
                ModuleName      = 'PowerLFM'
                Scope           = 'Context'
                Exactly         = $true
                Times           = 1
                ParameterFilter = {
                    $Uri -like 'https://ws.audioscrobbler.com/2.0*'
                }
            }
            Should -Invoke @siParams
        }

        It 'Should throw when an error is returned in the response' {
            Mock Invoke-LFMApiUri { throw 'Error' } -ModuleName 'PowerLFM'

            { Get-LFMUserPersonalTag -Tag Tag -TagType Artist } | Should -Throw 'Error'
        }
    }
}
