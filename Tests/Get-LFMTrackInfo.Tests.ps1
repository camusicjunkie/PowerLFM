Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Get-LFMTrackInfo: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command -Name 'Get-LFMTrackInfo')
    }

    It 'CmdletBinding should be declared' {
        $command.CmdletBinding | Should -BeTrue
    }

    It 'Should have track set as default parameter set' {
        $command.DefaultParameterSet | Should -Be 'track'
    }

    It 'Should contain an output type of PowerLFM.Track.Info' {
        $command.OutputType.Name | Should -Be 'PowerLFM.Track.Info'
    }

    Context 'ParameterSetName track' {

        It 'Should have a parameter set of track' {
            $command.ParameterSets.Name -contains 'track' | Should -BeTrue
        }

        $parameterSet = $command.ParameterSets | Where-Object Name -eq track

        Context 'Parameter [Track] attribute validation' {

            $parameter = $parameterSet.Parameters | Where-Object Name -eq Track

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

            It "Should have a position of 1" {
                $parameter.Position | Should -Be 1
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
    $contextMock = $mocks.'Get-LFMTrackInfo'.TrackInfo

    Describe 'Get-LFMTrackInfo: Unit' -Tag Unit {

        Mock Invoke-RestMethod

        Context 'Input' {

            It "Should throw when Track is null" {
                {Get-LFMTrackInfo -Track $null} | Should -Throw
            }
        }

        Context 'Execution' {

            Mock Foreach-Object

            $testCases = @(
                @{
                    set = 'track'
                    times = 5
                    gtiParams = @{
                        Track = 'Track'
                        Artist = 'Artist'
                    }
                }
                @{
                    set = 'track'
                    times = 6
                    gtiParams = @{
                        Track = 'Track'
                        Artist = 'Artist'
                        UserName = 'UserName'
                    }
                }
                @{
                    set = 'track'
                    times = 7
                    gtiParams = @{
                        Track = 'Track'
                        Artist = 'Artist'
                        UserName = 'UserName'
                        AutoCorrect = $true
                    }
                }
                @{
                    set = 'id'
                    times = 4
                    gtiParams = @{
                        Id = (New-Guid)
                    }
                }
            )

            It 'Should call Foreach-Object <times> times building url in <set> parameter set' -TestCases $testCases {
                param ($times, $gtiParams)

                Get-LFMTrackInfo @gtiParams

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
                $script:output = Get-LFMTrackInfo -Track Track -Artist Artist
            }

            It "Track should have name of $($contextMock.Track.Name)" {
                $output.Track | Should -Be $contextMock.Track.Name
            }

            It "Track should have artist name of $($contextMock.Track.Artist.Name)" {
                $output.Artist | Should -Be $contextMock.Track.Artist.Name
            }

            It "Track should have album name of $($contextMock.Track.Album.Title)" {
                $output.Album | Should -Be $contextMock.Track.Album.Title
            }

            It "Track should have url of $($contextMock.Track.Url)" {
                $output.Url | Should -Be $contextMock.Track.Url
            }

            It "Track should have listeners with a value of $($contextMock.Track.Listeners)" {
                $output.Listeners | Should -BeOfType [int]
                $output.Listeners | Should -Be $contextMock.Track.Listeners
            }

            It "Track should have playcount with a value of $($contextMock.Track.Playcount)" {
                $output.Playcount | Should -BeOfType [int]
                $output.Playcount | Should -Be $contextMock.Track.Playcount
            }

            It "Track first tag should have name of $($contextMock.Track.TopTags.Tag[0].Name)" {
                $output.Tags[0].Tag | Should -Be $contextMock.Track.TopTags.Tag[0].Name
            }

            It "Track second tag should have a url of $($contextMock.Track.TopTags.Tag[1].Url)" {
                $output.Tags[1].Url | Should -Be $contextMock.Track.TopTags.Tag[1].Url
            }

            It 'Track should have two tags' {
                $output.Tags | Should -HaveCount 2
            }

            It 'Track should not have more than two tags' {
                $output.Tags | Should -Not -BeNullOrEmpty
                $output.Tags | Should -Not -HaveCount 3
            }

            It "Track should have a user play count of $($contextMock.Track.UserPlayCount)" {
                $output = Get-LFMTrackInfo -Track Track -Artist Artist -UserName camusicjunkie
                $output.UserPlayCount | Should -Be $contextMock.Track.UserPlayCount
            }

            It "Track should have two tags when id parameter is used" {
                $output = Get-LFMTrackInfo -Id (New-Guid)
                $output.Tags | Should -HaveCount 2
            }
        }
    }
}

Describe 'Get-LFMTrackInfo: Integration' -Tag Integration {

    It "Integration test" {
        Set-ItResult -Skipped -Because 'the integration tests will be set up later'
    }
}
