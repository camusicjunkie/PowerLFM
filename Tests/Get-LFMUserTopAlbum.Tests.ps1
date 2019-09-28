Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Get-LFMUserTopAlbum: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command -Name 'Get-LFMUserTopAlbum')
    }

    It 'CmdletBinding should be declared' {
        $command.CmdletBinding | Should -BeTrue
    }

    It 'Should contain an output type of PowerLFM.User.TopAlbum' {
        $command.OutputType.Name | Should -Be 'PowerLFM.User.TopAlbum'
    }

    Context 'ParameterSetName __AllParameterSets' {

        It 'Should have a parameter set of __AllParameterSets' {
            $command.ParameterSets.Name -contains '__AllParameterSets' | Should -BeTrue
        }

        $parameterSet = $command.ParameterSets | Where-Object Name -eq __AllParameterSets

        Context 'Parameter [UserName] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq UserName

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It "Should be of type System.String" {
                $parameter.ParameterType.ToString() | Should -Be System.String
            }

            It 'Mandatory should be set to True' {
                $parameter.IsMandatory | Should -BeFalse
            }

            It 'ValueFromPipeline should be set to False' {
                $parameter.ValueFromPipeline | Should -BeFalse
            }

            It 'ValueFromPipelineByPropertyName should be set to True' {
                $parameter.ValueFromPipelineByPropertyName | Should -BeTrue
            }

            It 'ValueFromReminingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It "Should have a position of 0" {
                $parameter.Position | Should -Be 0
            }
        }

        Context 'Parameter [TimePeriod] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq TimePeriod

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It "Should be of type System.String" {
                $parameter.ParameterType.ToString() | Should -Be System.String
            }

            It 'Mandatory should be set to False' {
                $parameter.IsMandatory | Should -BeFalse
            }

            It 'ValueFromPipeline should be set to False' {
                $parameter.ValueFromPipeline | Should -BeFalse
            }

            It 'ValueFromPipelineByPropertyName should be set to False' {
                $parameter.ValueFromPipelineByPropertyName | Should -BeFalse
            }

            It 'ValueFromReminingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It "Should have a position of 1" {
                $parameter.Position | Should -Be 1
            }
        }

        Context 'Parameter [Limit] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq Limit

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It "Should be of type System.String" {
                $parameter.ParameterType.ToString() | Should -Be System.String
            }

            It 'Mandatory should be set to False' {
                $parameter.IsMandatory | Should -BeFalse
            }

            It 'ValueFromPipeline should be set to False' {
                $parameter.ValueFromPipeline | Should -BeFalse
            }

            It 'ValueFromPipelineByPropertyName should be set to False' {
                $parameter.ValueFromPipelineByPropertyName | Should -BeFalse
            }

            It 'ValueFromReminingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It "Should have a position of 2" {
                $parameter.Position | Should -Be 2
            }
        }

        Context 'Parameter [Page] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq Page

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It "Should be of type System.String" {
                $parameter.ParameterType.ToString() | Should -Be System.String
            }

            It 'Mandatory should be set to False' {
                $parameter.IsMandatory | Should -BeFalse
            }

            It 'ValueFromPipeline should be set to False' {
                $parameter.ValueFromPipeline | Should -BeFalse
            }

            It 'ValueFromPipelineByPropertyName should be set to False' {
                $parameter.ValueFromPipelineByPropertyName | Should -BeFalse
            }

            It 'ValueFromReminingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It "Should have a position of 3" {
                $parameter.Position | Should -Be 3
            }
        }
    }
}

InModuleScope PowerLFM {

    $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
    $contextMock = $mocks.'Get-LFMUserTopAlbum'.UserTopAlbum

    Describe 'Get-LFMUserTopAlbum: Unit' -Tag Unit {

        Mock Invoke-RestMethod

        Context 'Input' {

            It "Should throw when username is null" {
                {Get-LFMUserTopAlbum -UserName $null} | Should -Throw
            }

            It "Should throw when limit has more than 50 values" {
                Set-ItResult -Pending -Because 'the type needs to change on the limit parameter'

                $gutaParams = @{
                    UserName = 'UserName'
                    Limit = @(1..51)
                }
                {Get-LFMUserTopAlbum @gutaParams} | Should -Throw
            }

            It "Should not throw when limit has 1 to 50 values" {
                Set-ItResult -Pending -Because 'the type needs to change on the limit parameter'

                $gutaParams = @{
                    UserName = 'UserName'
                    Limit = @(1..50)
                }
                {Get-LFMUserTopAlbum @gutaParams} | Should -Not -Throw
            }
        }

        Context 'Execution' {

            Mock Foreach-Object

            $testCases = @(
                @{
                    times = 4
                    gutaParams = @{
                        UserName = 'UserName'
                    }
                }
                @{
                    times = 5
                    gutaParams = @{
                        UserName = 'UserName'
                        TimePeriod = 'Overall'
                    }
                }
                @{
                    times = 6
                    gutaParams = @{
                        UserName = 'UserName'
                        TimePeriod = 'Overall'
                        Limit = '5'
                    }
                }
                @{
                    times = 7
                    gutaParams = @{
                        UserName = 'UserName'
                        TimePeriod = 'Overall'
                        Limit = '5'
                        Page = '1'
                    }
                }
            )

            It 'Should call Foreach-Object <times> times building url' -TestCases $testCases {
                param ($times, $gutaParams)

                Get-LFMUserTopAlbum @gutaParams

                $amParams = @{
                    CommandName = 'Foreach-Object'
                    Exactly = $true
                    Times = $times
                    Scope = 'It'
                }
                Assert-MockCalled @amParams
            }
        }

        Context 'Output' {

            Mock Invoke-RestMethod {$contextMock}

            BeforeEach {
                $script:output = Get-LFMUserTopAlbum -UserName camusicjunkie
            }

            It "User first top album should have name of $($contextMock.TopAlbums.Album[0].Name)" {
                $output[0].Album | Should -Be $contextMock.TopAlbums.Album[0].Name
            }

            It "User first top album should have artist name of $($contextMock.TopAlbums.Album[0].Artist.Name)" {
                $output[0].Artist | Should -Be $contextMock.TopAlbums.Album[0].Artist.Name
            }

            It "User first top album should have url of $($contextMock.TopAlbums.Album[0].Url)" {
                $output[0].AlbumUrl | Should -Be $contextMock.TopAlbums.Album[0].Url
            }

            It "User first top album should have playcount with a value of $($contextMock.TopAlbums.Album[0].PlayCount)" {
                $output[0].PlayCount | Should -Be $contextMock.TopAlbums.Album[0].PlayCount
            }

            It "User second top album should have playcount with a value of $($contextMock.TopAlbums.Album[1].PlayCount)" {
                $output[1].PlayCount | Should -Be $contextMock.TopAlbums.Album[1].PlayCount
            }

            It "User second top album should have url of $($contextMock.TopAlbums.Album[1].Url)" {
                $output[1].AlbumUrl | Should -Be $contextMock.TopAlbums.Album[1].Url
            }

            It "User second top album should have artist id with a value of $($contextMock.TopAlbums.Album[1].Artist.Mbid)" {
                $output[1].ArtistId | Should -Be $contextMock.TopAlbums.Album[1].Artist.Mbid
            }

            It "User second top album should have artist url of $($contextMock.TopAlbums.Album[1].Artist.Url)" {
                $output[1].ArtistUrl | Should -Be $contextMock.TopAlbums.Album[1].Artist.Url
            }

            It 'User should have two top albums' {
                $output.Album | Should -HaveCount 2
            }

            It 'User should not have more than two top albums' {
                $output.Album | Should -Not -BeNullOrEmpty
                $output.Album | Should -Not -HaveCount 3
            }
        }
    }
}

Describe 'Get-LFMUserTopAlbum: Integration' -Tag Integration {

    It "Integration test" {
        Set-ItResult -Skipped -Because 'the integration tests will be set up later'
    }
}
