BeforeAll {
    Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1 -Force
}

Describe 'Get-LFMAlbumInfo: Interface' -Tag Interface {

    BeforeAll {
        $command = Get-Command -Name 'Get-LFMAlbumInfo'
    }

    It 'CmdletBinding should be declared' {
        $command.CmdletBinding | Should -BeTrue
    }

    It 'Should have album set as default parameter set' {
        $command.DefaultParameterSet | Should -Be 'album'
    }

    It 'Should contain an output type of PowerLFM.Album.Info' {
        $command.OutputType.Name | Should -Be 'PowerLFM.Album.Info'
    }

    Context 'ParameterSetName album' {

        It 'Should have a parameter set of album' {
            $command.ParameterSets.Name | Should -Contain 'album'
        }

        BeforeAll {
            $parameterSet = $command.ParameterSets | Where-Object Name -eq album
        }

        Context 'Parameter [Album] attribute validation' {

            BeforeAll {
                $parameter = $parameterSet.Parameters | Where-Object Name -eq Album
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

            It 'Should have a position of 1' {
                $parameter.Position | Should -Be 1
            }
        }

        Context 'Parameter [UserName] attribute validation' {

            BeforeAll {
                $parameter = $parameterSet.Parameters | Where-Object Name -eq UserName
            }

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It 'Should be of type System.String' {
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

        Context 'Parameter [UserName] attribute validation' {

            BeforeAll {
                $parameter = $parameterSet.Parameters | Where-Object Name -eq UserName
            }

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It 'Should be of type System.String' {
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

Describe 'Get-LFMAlbumInfo: Unit' -Tag Unit {

    BeforeAll {
        Mock Remove-CommonParameter {
            [hashtable] @{
                Album  = 'Album'
                Artist = 'Artist'
            }
        } -ModuleName 'PowerLFM'
        Mock ConvertTo-LFMParameter -ModuleName 'PowerLFM'
        Mock New-LFMApiQuery -ModuleName 'PowerLFM'
        Mock Invoke-LFMApiUri { $contextMock } -ModuleName 'PowerLFM'
    }

    Context 'Input' {

        It 'Should throw when album is null' {
            { Get-LFMAlbumInfo -Album $null } | Should -Throw
        }
    }

    Context 'Execution' {

        BeforeAll {
            Get-LFMAlbumInfo -Album Album -Artist Artist
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
        $contextMock = $mocks.'Get-LFMAlbumInfo'.AlbumInfo

        #endregion Discovery

        BeforeAll {
            $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
            $contextMock = $mocks.'Get-LFMAlbumInfo'.AlbumInfo

            $output = Get-LFMAlbumInfo -Album Album -Artist Artist
        }

        It "Album should have name of $($contextMock.Album.Name)" {
            $output.Album | Should -Be $contextMock.Album.Name
        }

        It "Album should have artist name of $($contextMock.Album.Artist)" {
            $output.Artist | Should -Be $contextMock.Album.Artist
        }

        It "Album should have id of $($contextMock.Album.Mbid)" {
            $output.Id | Should -Be $contextMock.Album.Mbid
        }

        It "Album should have url of $($contextMock.Album.Url)" {
            $output.Url | Should -Be $contextMock.Album.Url
        }

        It "Album should have listeners with a value of $($contextMock.Album.Listeners)" {
            $output.Listeners | Should -BeOfType [int]
            $output.Listeners | Should -Be $contextMock.Album.Listeners
        }

        It "Album should have playcount with a value of $($contextMock.Album.PlayCount)" {
            $output.PlayCount | Should -BeOfType [int]
            $output.PlayCount | Should -Be $contextMock.Album.PlayCount
        }

        It "Album first track should have name of $($contextMock.Album.Tracks.Track[0].Name)" {
            $output.Tracks[0].Track | Should -Be $contextMock.Album.Tracks.Track[0].Name
        }

        It "Album second track should have a duration of $($contextMock.Album.Tracks.Track[1].Duration)" {
            $output.Tracks[1].Duration | Should -Be $contextMock.Album.Tracks.Track[1].Duration
        }

        It 'Album should have two tracks' {
            $output.Tracks | Should -HaveCount 2
        }

        It 'Album should not have more than two tracks' {
            $output.Tracks | Should -Not -BeNullOrEmpty
            $output.Tracks | Should -Not -HaveCount 3
        }

        It "Album first tag should have name of $($contextMock.Album.Tags.Tag[0].Name)" {
            $output.Tags[0].Tag | Should -Be $contextMock.Album.Tags.Tag[0].Name
        }

        It "Album second tag should have url of $($contextMock.Album.Tags.Tag[1].Url)" {
            $output.Tags[1].Url | Should -Be $contextMock.Album.Tags.Tag[1].Url
        }

        It 'Album should have two tags' {
            $output.Tags | Should -HaveCount 2
        }

        It 'Album should not have more than two tags' {
            $output.Tags | Should -Not -HaveCount 3
        }

        It "Album should have summary of '$($contextMock.Album.Wiki.Summary)'" {
            $output.Summary | Should -BeExactly $contextMock.Album.Wiki.Summary
        }

        It "Album should have a user play count of $($contextMock.Album.UserPlayCount)" {
            $output = Get-LFMAlbumInfo -Artist Artist -Album Album -UserName camusicjunkie
            $output.UserPlayCount | Should -Be $contextMock.Album.UserPlayCount
        }

        It 'Album should have two tracks when id parameter is used' {
            $output = Get-LFMAlbumInfo -Id (New-Guid)
            $output.Tracks | Should -HaveCount 2
        }

        It 'Should call the correct Last.fm get method' {
            Get-LFMAlbumInfo -Album Album -Artist Artist

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

            { Get-LFMAlbumInfo -Album Album -Artist Artist } | Should -Throw 'Error'
        }
    }
}
