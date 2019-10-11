Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Get-LFMArtistInfo: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command -Name 'Get-LFMArtistInfo')
    }

    It 'CmdletBinding should be declared' {
        $command.CmdletBinding | Should -BeTrue
    }

    It 'Should have artist set as default parameter set' {
        $command.DefaultParameterSet | Should -Be 'artist'
    }

    It 'Should contain an output type of PowerLFM.Artist.Info' {
        $command.OutputType.Name | Should -Be 'PowerLFM.Artist.Info'
    }

    Context 'ParameterSetName artist' {

        It 'Should have a parameter set of artist' {
            $command.ParameterSets.Name -contains 'artist' | Should -BeTrue
        }

        $parameterSet = $command.ParameterSets | Where-Object Name -eq artist

        Context 'Parameter [Artist] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq Artist

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

        Context 'Parameter [UserName] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq UserName

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

            It "Should have a position of -2147483648" {
                $parameter.Position | Should -Be -2147483648
            }
        }

        Context 'Parameter [AutoCorrect] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq AutoCorrect

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It "Should be of type System.Management.Automation.SwitchParameter" {
                $parameter.ParameterType.ToString() | Should -Be System.Management.Automation.SwitchParameter
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

            It "Should have a position of -2147483648" {
                $parameter.Position | Should -Be -2147483648
            }
        }
    }

    Context 'ParameterSetName id' {

        It 'Should have a parameter set of id' {
            $command.ParameterSets.Name -contains 'id' | Should -BeTrue
        }

        $parameterSet = $command.ParameterSets | Where-Object Name -eq id

        Context 'Parameter [Id] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq Id

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It "Should be of type System.Guid" {
                $parameter.ParameterType.ToString() | Should -Be System.Guid
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

            It "Should have a position of -2147483648" {
                $parameter.Position | Should -Be -2147483648
            }
        }

        Context 'Parameter [UserName] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq UserName

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

            It "Should have a position of -2147483648" {
                $parameter.Position | Should -Be -2147483648
            }
        }

        Context 'Parameter [AutoCorrect] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq AutoCorrect

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It "Should be of type System.Management.Automation.SwitchParameter" {
                $parameter.ParameterType.ToString() | Should -Be System.Management.Automation.SwitchParameter
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

            It "Should have a position of -2147483648" {
                $parameter.Position | Should -Be -2147483648
            }
        }
    }
}

InModuleScope PowerLFM {

    $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
    $contextMock = $mocks.'Get-LFMArtistInfo'.ArtistInfo

    Describe 'Get-LFMArtistInfo: Unit' -Tag Unit {

        Mock Invoke-RestMethod

        Context 'Input' {

            It 'Should throw when artist is null' {
                {Get-LFMArtistInfo -Artist $null} | Should -Throw
            }
        }

        Context 'Execution' {

            Mock Foreach-Object

            $testCases = @(
                @{
                    set = 'artist'
                    times = 4
                    gaiParams = @{
                        Artist = 'Artist'
                    }
                }
                @{
                    set = 'artist'
                    times = 5
                    gaiParams = @{
                        Artist = 'Artist'
                        UserName = 'camusicjunkie'
                    }
                }
                @{
                    set = 'artist'
                    times = 6
                    gaiParams = @{
                        Artist = 'Artist'
                        UserName = 'camusicjunkie'
                        AutoCorrect = $true
                    }
                }
                @{
                    set = 'id'
                    times = 4
                    gaiParams = @{
                        Id = (New-Guid)
                    }
                }
            )

            It 'Should call Foreach-Object <times> times building url in <set> parameter set' -TestCases $testCases {
                param ($times, $gaiParams)

                Get-LFMArtistInfo @gaiParams

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
                $script:output = Get-LFMArtistInfo -Artist Artist
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

            It "Artist should have playcount with a value of $($contextMock.Artist.Stats.Playcount)" {
                $output.Playcount | Should -BeOfType [int]
                $output.Playcount | Should -Be $contextMock.Artist.Stats.Playcount
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

            It "Artist should have two similar artists when id parameter is used" {
                $output = Get-LFMArtistInfo -Id (New-Guid)
                $output.SimilarArtists | Should -HaveCount 2
            }
        }
    }
}

Describe 'Get-LFMArtistInfo: Integration' -Tag Integration {

    It "Integration test" {
        Set-ItResult -Skipped -Because 'the integration tests will be set up later'
    }
}
