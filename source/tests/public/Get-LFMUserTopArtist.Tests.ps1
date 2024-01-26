# BeforeAll {
#     Remove-Module -Name PowerLFM -ErrorAction Ignore
#     Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1
# }


Describe 'Get-LFMUserTopArtist: Unit' -Tag Unit {

    BeforeDiscovery {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMUserTopArtist'.UserTopArtist
    }

    BeforeAll {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMUserTopArtist'.UserTopArtist

        Mock Remove-CommonParameter {
            [hashtable] @{ }
        } -ModuleName 'PowerLFM'
        Mock ConvertTo-LFMParameter -ModuleName 'PowerLFM'
        Mock New-LFMApiQuery -ModuleName 'PowerLFM'
        Mock Invoke-LFMApiUri { $contextMock } -ModuleName 'PowerLFM'
    }

    Context 'Input' {

        It 'Should throw when username is null' {
            { Get-LFMUserTopArtist -UserName $null } | Should -Throw
        }

        It 'Should throw when limit has more than 50 values' {
            { Get-LFMUserTopArtist -Limit 51 } | Should -Throw
        }

        It 'Should not throw when limit has a value of 1 to 50' {
            { Get-LFMUserTopArtist -Limit 50 } | Should -Not -Throw
        }
    }

    Context 'Execution' {

        BeforeAll {
            Get-LFMUserTopArtist
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
            $output = Get-LFMUserTopArtist
        }

        It "User first top artist should have name of $($contextMock.TopArtists.Artist[0].Name)" {
            $output[0].Artist | Should -Be $contextMock.TopArtists.Artist[0].Name
        }

        It "User first top artist should have id of $($contextMock.TopArtists.Artist[0].Mbid)" {
            $output[0].Id | Should -Be $contextMock.TopArtists.Artist[0].Mbid
        }

        It "User second top artist should have url of $($contextMock.TopArtists.Artist[1].Url)" {
            $output[1].Url | Should -Be $contextMock.TopArtists.Artist[1].Url
        }

        It "User second top artist should have playcount with a value of $($contextMock.TopArtists.Artist[1].PlayCount)" {
            $output[1].PlayCount | Should -BeOfType [int]
            $output[1].PlayCount | Should -Be $contextMock.TopArtists.Artist[1].PlayCount
        }

        It 'User should have two top artists' {
            $output.Artist | Should -HaveCount 2
        }

        It 'User should not have more than two top artists' {
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

            { Get-LFMUserTopArtist } | Should -Throw 'Error'
        }
    }
}
