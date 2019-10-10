Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Search-LFMAlbum: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command -Name 'Search-LFMAlbum')
    }

    It 'CmdletBinding should be declared' {
        $command.CmdletBinding | Should -BeTrue
    }

    It 'Should contain an output type of PowerLFM.Album.Search' {
        $command.OutputType.Name | Should -Be 'PowerLFM.Album.Search'
    }

    Context 'ParameterSetName __AllParameterSets' {

        It 'Should have a parameter set of __AllParameterSets' {
            $command.ParameterSets.Name -contains '__AllParameterSets' | Should -BeTrue
        }

        $parameterSet = $command.ParameterSets | Where-Object Name -eq __AllParameterSets

        Context 'Parameter [Album] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq Album

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It "Should be of type System.String" {
                $parameter.ParameterType.ToString() | Should -Be System.String
            }

            It 'Mandatory should be set to True' {
                $parameter.IsMandatory | Should -BeTrue
            }

            It 'ValueFromPipeline should be set to False' {
                $parameter.ValueFromPipeline | Should -BeFalse
            }

            It 'ValueFromPipelineByPropertyName should be set to True' {
                $parameter.ValueFromPipelineByPropertyName | Should -BeTrue
            }

            It 'ValueFromRemainingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It "Should have a position of 0" {
                $parameter.Position | Should -Be 0
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

            It 'ValueFromRemainingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It "Should have a position of 1" {
                $parameter.Position | Should -Be 1
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

            It 'ValueFromRemainingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It "Should have a position of 2" {
                $parameter.Position | Should -Be 2
            }
        }
    }
}

InModuleScope PowerLFM {

    $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
    $contextMock = $mocks.'Search-LFMAlbum'.Album

    Describe 'Search-LFMAlbum: Unit' -Tag Unit {

        Mock Invoke-RestMethod

        Context 'Input' {

            It "Should throw when album is null" {
                {Search-LFMAlbum -Album $null} | Should -Throw
            }
        }

        Context 'Execution' {

            Mock Foreach-Object

            $testCases = @(
                @{
                    times = 4
                    saParams = @{
                        Album = 'Album'
                    }
                }
                @{
                    times = 5
                    saParams = @{
                        Album = 'Album'
                        Limit = '5'
                    }
                }
                @{
                    times = 6
                    saParams = @{
                        Album = 'Album'
                        Limit = '5'
                        Page = '1'
                    }
                }
            )

            It 'Should call Foreach-Object <times> times building url' -TestCases $testCases {
                param ($times, $saParams)

                Search-LFMAlbum @saParams

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

            $output = Search-LFMAlbum -Album Album

            It "Searched first album should have name of $($contextMock.Results.AlbumMatches.Album[0].Name)" {
                $output[0].Album | Should -Be $contextMock.Results.AlbumMatches.Album[0].Name
            }

            It "Searched first album should have artist name of $($contextMock.Results.AlbumMatches.Album[0].Artist)" {
                $output[0].Artist | Should -Be $contextMock.Results.AlbumMatches.Album[0].Artist
            }

            It "Searched first album should have url of $($contextMock.Results.AlbumMatches.Album[0].Url)" {
                $output[0].Url | Should -Be $contextMock.Results.AlbumMatches.Album[0].Url
            }

            It "Searched second album should have url of $($contextMock.Results.AlbumMatches.Album[1].Url)" {
                $output[1].Url | Should -Be $contextMock.Results.AlbumMatches.Album[1].Url
            }

            It "Searched second album should have artist id with a value of $($contextMock.Results.AlbumMatches.Album[1].Mbid)" {
                $output[1].Id | Should -Be $contextMock.Results.AlbumMatches.Album[1].Mbid
            }

            It 'Searched result should have two albums' {
                $output.Album | Should -HaveCount 2
            }

            It 'Searched result should not have more than two albums' {
                $output.Album | Should -Not -BeNullOrEmpty
                $output.Album | Should -Not -HaveCount 3
            }
        }
    }
}

Describe 'Search-LFMAlbum: Integration' -Tag Integration {

    It "Integration test" {
        Set-ItResult -Skipped -Because 'the integration tests will be set up later'
    }
}
