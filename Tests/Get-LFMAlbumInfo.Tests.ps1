Remove-Module -Name PowerLFM -ErrorAction Ignore
Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1

Describe 'Get-LFMAlbumInfo: Interface' -Tag Interface {

    BeforeAll {
        $script:command = (Get-Command -Name 'Get-LFMAlbumInfo')
    }

    It 'CmdletBinding should be declared' {
        $command.CmdletBinding | Should -BeTrue
    }

    It 'Should have album set as default parameter set' {
        $command.DefaultParameterSet | Should -Be 'album'
    }

    It 'Should contain an output type of PowerLFM.Album.Info' {
        $command.OutputType.Name -contains 'PowerLFM.Album.Info' | Should -BeTrue
    }

    Context 'ParameterSetName album' {

        It 'Should have a parameter set of album' {
            $command.ParameterSets.Name -contains 'album' | Should -BeTrue
        }

        $parameterSet = $command.ParameterSets | Where-Object Name -eq album

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

            It 'ValueFromReminingArguments should be set to False' {
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

            It 'ValueFromReminingArguments should be set to False' {
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

            It 'ValueFromReminingArguments should be set to False' {
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

            It 'ValueFromReminingArguments should be set to False' {
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

            It 'ValueFromReminingArguments should be set to False' {
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

            It 'ValueFromReminingArguments should be set to False' {
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
    $contextMock = $mocks.'Get-LFMAlbumInfo'.AlbumInfo

    Describe 'Get-LFMAlbumInfo: Unit' -Tag Unit {

        Context 'Input' {

            It 'Should throw when Album is null' {
                {Get-LFMAlbumInfo -Album $null} | Should -Throw
            }
        }

        Context 'Execution' {

            Mock Invoke-RestMethod
            Mock Foreach-Object

            $testCases = @(
                @{
                    set = 'album'
                    times = 5
                    gaiParams = @{
                        Album = 'Album'
                        Artist = 'Artist'
                    }
                }
                @{
                    set = 'album'
                    times = 6
                    gaiParams = @{
                        Album = 'Album'
                        Artist = 'Artist'
                        UserName = 'camusicjunkie'
                    }
                }
                @{
                    set = 'album'
                    times = 7
                    gaiParams = @{
                        Album = 'Album'
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

                Get-LFMAlbumInfo @gaiParams

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
                $script:output = Get-LFMAlbumInfo -Album Album -Artist Artist
            }

            It 'Album should output object of type PowerLFM.Album.Info' {
                $output.PSTypeNames[0] | Should -Be 'PowerLFM.Album.Info'
            }

            It "Album should have name of $($contextMock.album.name)" {
                $output.Album | Should -Be $contextMock.album.name
            }

            It "Album should have artist name of $($contextMock.album.artist)" {
                $output.Artist | Should -Be $contextMock.album.artist
            }

            It "Album should have id of $($contextMock.album.mbid)" {
                $output.Id | Should -Be $contextMock.album.mbid
            }

            It "Album should have url of $($contextMock.album.url)" {
                $output.Url | Should -Be $contextMock.album.url
            }

            It "Album should have listeners with a value of $($contextMock.album.listeners)" {
                $output.Listeners | Should -BeOfType [int]
                $output.Listeners | Should -Be $contextMock.album.listeners
            }

            It "Album should have playcount with a value of $($contextMock.album.playcount)" {
                $output.Playcount | Should -BeOfType [int]
                $output.Playcount | Should -Be $contextMock.album.playcount
            }

            It "Album first track should have name of $($contextMock.album.tracks.track[0].name)" {
                $output.Tracks[0].Track | Should -Be $contextMock.album.tracks.track[0].name
            }

            It "Album second track should have a duration of $($contextMock.album.tracks.track[1].duration)" {
                $output.Tracks[1].Duration | Should -Be $contextMock.album.tracks.track[1].duration
            }

            It 'Album should have two tracks' {
                $output.Tracks | Should -HaveCount 2
            }

            It 'Album should not have more than two tracks' {
                $output.Tracks | Should -Not -BeNullOrEmpty
                $output.Tracks | Should -Not -HaveCount 3
            }

            It "Album first tag should have name of $($contextMock.album.tags.tag[0].name)" {
                $output.Tags[0].Tag | Should -Be $contextMock.album.tags.tag[0].name
            }

            It "Album second tag should have url of $($contextMock.album.tags.tag[1].url)" {
                $output.Tags[1].Url | Should -Be $contextMock.album.tags.tag[1].url
            }

            It 'Album should have two tags' {
                $output.Tags | Should -HaveCount 2
            }

            It 'Album should not have more than two tags' {
                $output.Tags | Should -Not -HaveCount 3
            }

            It "Album should have summary of '$($contextMock.album.wiki.summary)'" {
                $output.Summary | Should -BeExactly $contextMock.album.wiki.summary
            }

            It "Album should have a user play count of $($contextMock.album.userplaycount)" {
                $output = Get-LFMAlbumInfo -Artist Artist -Album Album -UserName camusicjunkie
                $output.UserPlayCount | Should -Be $contextMock.album.userplaycount
            }
        }
    }
}

Describe 'Get-LFMAlbumInfo: Integration' -Tag Integration {

    It "Integration test" {
        Set-ItResult -Skipped -Because 'the integration tests will be set up later'
    }
}
