Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Get-LFMTagTopAlbum: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command -Name 'Get-LFMTagTopAlbum')
    }

    It 'CmdletBinding should be declared' {
        $command.CmdletBinding | Should -BeTrue
    }

    It 'Should contain an output type of PowerLFM.Tag.TopAlbums' {
        $command.OutputType.Name | Should -Be 'PowerLFM.Tag.TopAlbums'
    }

    Context 'ParameterSetName __AllParameterSets' {

        It 'Should have a parameter set of __AllParameterSets' {
            $command.ParameterSets.Name -contains '__AllParameterSets' | Should -BeTrue
        }

        $parameterSet = $command.ParameterSets | Where-Object Name -eq __AllParameterSets

        Context 'Parameter [Tag] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq Tag

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

            It 'ValueFromReminingArguments should be set to False' {
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

            It 'ValueFromReminingArguments should be set to False' {
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

            It 'ValueFromReminingArguments should be set to False' {
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
    $contextMock = $mocks.'Get-LFMTagTopAlbum'.TagTopAlbum

    Describe 'Get-LFMTagTopAlbum: Unit' -Tag Unit {

        Mock Invoke-RestMethod

        Context 'Input' {

            It "Should throw when Tag is null" {
                {Get-LFMTagTopAlbum -Tag $null} | Should -Throw
            }
        }

        Context 'Execution' {

            Mock Foreach-Object

            $testCases = @(
                @{
                    times = 4
                    gttaParams = @{
                        Tag = 'Tag'
                    }
                }
                @{
                    times = 5
                    gttaParams = @{
                        Tag = 'Tag'
                        Limit = '5'
                    }
                }
                @{
                    times = 6
                    gttaParams = @{
                        Tag = 'Tag'
                        Limit = '5'
                        Page = '1'
                    }
                }
            )

            It 'Should call Foreach-Object <times> times building url' -TestCases $testCases {
                param ($times, $gttaParams)

                Get-LFMTagTopAlbum @gttaParams

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
                $script:output = Get-LFMTagTopAlbum -Tag Tag
            }

            It "Tag first top album should have name of $($contextMock.Albums.Album[0].Name)" {
                $output[0].Album | Should -Be $contextMock.Albums.Album[0].Name
            }

            It "Tag first top album should have artist name of $($contextMock.Albums.Album[0].Artist.Name)" {
                $output[0].Artist | Should -Be $contextMock.Albums.Album[0].Artist.Name
            }

            It "Tag first top album should have url of $($contextMock.Albums.Album[0].Url)" {
                $output[0].AlbumUrl | Should -Be $contextMock.Albums.Album[0].Url
            }

            It "Tag first top album should have rank with a value of $($contextMock.Albums.Album[0].'@attr'.Rank)" {
                $output[0].Rank | Should -Be $contextMock.Albums.Album[0].'@attr'.Rank
            }

            It "Tag second top album should have rank with a value of $($contextMock.Albums.Album[1].'@attr'.Rank)" {
                $output[1].Rank | Should -Be $contextMock.Albums.Album[1].'@attr'.Rank
            }

            It "Tag second top album should have url of $($contextMock.Albums.Album[1].Url)" {
                $output[1].AlbumUrl | Should -Be $contextMock.Albums.Album[1].Url
            }

            It "Tag second top album should have artist id with a value of $($contextMock.Albums.Album[1].Artist.Mbid)" {
                $output[1].ArtistId | Should -Be $contextMock.Albums.Album[1].Artist.Mbid
            }

            It "Tag second top album should have artist url of $($contextMock.Albums.Album[1].Artist.Url)" {
                $output[1].ArtistUrl | Should -Be $contextMock.Albums.Album[1].Artist.Url
            }

            It 'Tag should have two top albums' {
                $output.Album | Should -HaveCount 2
            }

            It 'Tag should not have more than two top albums' {
                $output.Album | Should -Not -BeNullOrEmpty
                $output.Album | Should -Not -HaveCount 3
            }
        }
    }
}

Describe 'Get-LFMTagTopAlbum: Integration' -Tag Integration {

    It "Integration test" {
        Set-ItResult -Skipped -Because 'the integration tests will be set up later'
    }
}
