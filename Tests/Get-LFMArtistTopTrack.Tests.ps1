BeforeAll {
    Remove-Module -Name PowerLFM -ErrorAction Ignore
    Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1
}

Describe 'Get-LFMArtistTopTrack: Interface' -Tag Interface {

    BeforeAll {
        $command = Get-Command -Name 'Get-LFMArtistTopTrack'
    }

    It 'CmdletBinding should be declared' {
        $command.CmdletBinding | Should -BeTrue
    }

    It 'Should have artist set as default parameter set' {
        $command.DefaultParameterSet | Should -Be 'artist'
    }

    It 'Should contain an output type of PowerLFM.Artist.Track' {
        $command.OutputType.Name | Should -Be 'PowerLFM.Artist.Track'
    }

    Context 'ParameterSetName artist' {

        It 'Should have a parameter set of artist' {
            $command.ParameterSets.Name | Should -Contain 'artist'
        }

        BeforeAll {
            $parameterSet = $command.ParameterSets | Where-Object Name -eq artist
        }

        Context 'Parameter [Artist] attribute validation' {

            BeforeAll {
                $parameter = $parameterSet.Parameters | Where-Object Name -eq Artist
            }

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It 'Should be of type System.String' {
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

            It 'Should have a position of 0' {
                $parameter.Position | Should -Be 0
            }
        }

        Context 'Parameter [Limit] attribute validation' {

            BeforeAll {
                $parameter = $parameterSet.Parameters | Where-Object Name -eq Limit
            }

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It 'Should be of type System.Int32' {
                $parameter.ParameterType.ToString() | Should -Be System.Int32
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

            It 'Should have a position of -2147483648' {
                $parameter.Position | Should -Be -2147483648
            }
        }

        Context 'Parameter [Page] attribute validation' {

            BeforeAll {
                $parameter = $parameterSet.Parameters | Where-Object Name -eq Page
            }

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It 'Should be of type System.Int32' {
                $parameter.ParameterType.ToString() | Should -Be System.Int32
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

            It 'Should have a position of -2147483648' {
                $parameter.Position | Should -Be -2147483648
            }
        }

        Context 'Parameter [AutoCorrect] attribute validation' {

            BeforeAll {
                $parameter = $parameterSet.Parameters | Where-Object Name -eq AutoCorrect
            }

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It 'Should be of type System.Management.Automation.SwitchParameter' {
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

            It 'Should have a position of -2147483648' {
                $parameter.Position | Should -Be -2147483648
            }
        }
    }

    Context 'ParameterSetName id' {

        It 'Should have a parameter set of id' {
            $command.ParameterSets.Name | Should -Contain 'id'
        }

        BeforeAll {
            $parameterSet = $command.ParameterSets | Where-Object Name -eq id
        }

        Context 'Parameter [Id] attribute validation' {

            BeforeAll {
                $parameter = $parameterSet.Parameters | Where-Object Name -eq Id
            }

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It 'Should be of type System.Guid' {
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

            It 'Should have a position of -2147483648' {
                $parameter.Position | Should -Be -2147483648
            }
        }

        Context 'Parameter [Limit] attribute validation' {

            BeforeAll {
                $parameter = $parameterSet.Parameters | Where-Object Name -eq Limit
            }

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It 'Should be of type System.Int32' {
                $parameter.ParameterType.ToString() | Should -Be System.Int32
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

            It 'Should have a position of -2147483648' {
                $parameter.Position | Should -Be -2147483648
            }
        }

        Context 'Parameter [Page] attribute validation' {

            BeforeAll {
                $parameter = $parameterSet.Parameters | Where-Object Name -eq Page
            }

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It 'Should be of type System.Int32' {
                $parameter.ParameterType.ToString() | Should -Be System.Int32
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

            It 'Should have a position of -2147483648' {
                $parameter.Position | Should -Be -2147483648
            }
        }

        Context 'Parameter [AutoCorrect] attribute validation' {

            BeforeAll {
                $parameter = $parameterSet.Parameters | Where-Object Name -eq AutoCorrect
            }

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It 'Should be of type System.Management.Automation.SwitchParameter' {
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

            It 'Should have a position of -2147483648' {
                $parameter.Position | Should -Be -2147483648
            }
        }
    }
}

Describe 'Get-LFMArtistTopTrack: Unit' -Tag Unit {

    BeforeAll {
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
            { Get-LFMArtistTopTrack -Artist $null } | Should -Throw
        }
    }

    Context 'Execution' {

        BeforeAll {
            Get-LFMArtistTopTrack -Artist Artist
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

        #region Discovery

        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMArtistTopTrack'.ArtistTopTrack

        #endregion Discovery

        BeforeAll {
            $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
            $contextMock = $mocks.'Get-LFMArtistTopTrack'.ArtistTopTrack

            $output = Get-LFMArtistTopTrack -Artist Artist
        }

        It "Artist first top track should have name of $($contextMock.Toptracks.Track[0].Name)" {
            $output[0].Track | Should -Be $contextMock.Toptracks.Track[0].Name
        }

        It "Artist first top track should have id of $($contextMock.Toptracks.Track[0].Mbid)" {
            $output[0].Id | Should -Be $contextMock.Toptracks.Track[0].Mbid
        }

        It "Artist first top track should have listeners with a value of $($contextMock.Toptracks.Track[0].Listeners)" {
            $output[0].Listeners | Should -BeOfType [int]
            $output[0].Listeners | Should -Be $contextMock.Toptracks.Track[0].Listeners
        }

        It "Artist second top track should have listeners with a value of $($contextMock.Toptracks.Track[1].Listeners)" {
            $output[1].Listeners | Should -BeOfType [int]
            $output[1].Listeners | Should -Be $contextMock.Toptracks.Track[1].Listeners
        }

        It "Artist second top track should have url of $($contextMock.Toptracks.Track[1].Url)" {
            $output[1].Url | Should -Be $contextMock.Toptracks.Track[1].Url
        }

        It "Artist second top track should have playcount with a value of $($contextMock.Toptracks.Track[1].PlayCount)" {
            $output[1].PlayCount | Should -BeOfType [int]
            $output[1].PlayCount | Should -Be $contextMock.Toptracks.Track[1].PlayCount
        }

        It 'Artist should have two top tracks' {
            $output.Album | Should -HaveCount 2
        }

        It 'Artist should not have more than two top tracks' {
            $output.Album | Should -Not -BeNullOrEmpty
            $output.Album | Should -Not -HaveCount 3
        }

        It 'Artist should have two top tracks when id parameter is used' {
            $output = Get-LFMArtistTopTrack -Id (New-Guid)
            $output.Track | Should -HaveCount 2
        }

        It 'Should call the correct Last.fm get method' {
            Get-LFMArtistTopTrack -Artist Artist

            $siParams = @{
                CommandName     = 'Invoke-LFMApiUri'
                ModuleName      = 'PowerLFM'
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

            { Get-LFMArtistTopTrack -Artist Artist } | Should -Throw 'Error'
        }
    }
}
