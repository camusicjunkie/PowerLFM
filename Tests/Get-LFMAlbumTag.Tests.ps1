BeforeAll {
    Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1 -Force
}

Describe 'Get-LFMAlbumTag: Interface' -Tag Interface {

    BeforeAll {
        $command = Get-Command -Name 'Get-LFMAlbumTag'
    }

    It 'CmdletBinding should be declared' {
        $command.CmdletBinding | Should -BeTrue
    }

    It 'Should have album set as default parameter set' {
        $command.DefaultParameterSet | Should -Be 'album'
    }

    It 'Should contain an output type of PowerLFM.Album.Tag' {
        $command.OutputType.Name | Should -Be 'PowerLFM.Album.Tag'
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

Describe 'Get-LFMAlbumTag: Unit' -Tag Unit {

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
            { Get-LFMAlbumTag -Album $null } | Should -Throw
        }
    }

    Context 'Execution' {

        BeforeAll {
            Get-LFMAlbumTag -Album Album -Artist Artist
        }

        It 'Should remove common parameters from bound parameters' {
            $amParams = @{
                CommandName     = 'Remove-CommonParameter'
                ModuleName      = 'PowerLFM'
                Scope           = 'Context'
                Exactly         = $true
                Times           = 1
                ParameterFilter = {
                    $PSBoundParameters
                }
            }
            Assert-MockCalled @amParams
        }

        It 'Should convert parameters to format API expects after signing' {
            $amParams = @{
                CommandName = 'ConvertTo-LFMParameter'
                ModuleName  = 'PowerLFM'
                Scope       = 'Context'
                Exactly     = $true
                Times       = 1
            }
            Assert-MockCalled @amParams
        }

        It 'Should take hashtable and build a query for a uri' {
            $amParams = @{
                CommandName = 'New-LFMApiQuery'
                ModuleName  = 'PowerLFM'
                Scope       = 'Context'
                Exactly     = $true
                Times       = 1
            }
            Assert-MockCalled @amParams
        }
    }

    Context 'Output' {

        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMAlbumTag'.AlbumTag

        BeforeAll {
            $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
            $contextMock = $mocks.'Get-LFMAlbumTag'.AlbumTag

            $output = Get-LFMAlbumTag -Album Album -Artist Artist
        }

        It "Album first tag should have name of $($contextMock.Tags.Tag[0].Name)" {
            $output[0].Tag | Should -Be $contextMock.Tags.Tag[0].Name
        }

        It "Album second tag should have url of $($contextMock.Tags.Tag[1].Url)" {
            $output[1].Url | Should -Be $contextMock.Tags.Tag[1].Url
        }

        It 'Album should have two tags' {
            $output.Tag | Should -HaveCount 2
        }

        It 'Album should not have more than two tags' {
            $output.Tag | Should -Not -BeNullOrEmpty
            $output.Tag | Should -Not -HaveCount 3
        }

        It 'Album should have two tags when id parameter is used' {
            $output = Get-LFMAlbumTag -Id (New-Guid)
            $output.Tags | Should -HaveCount 2
        }

        It 'Should call the correct Last.fm get method' {
            Get-LFMAlbumTag -Album Album -Artist Artist

            $amParams = @{
                CommandName     = 'Invoke-LFMApiUri'
                ModuleName      = 'PowerLFM'
                Scope           = 'It'
                Exactly         = $true
                Times           = 1
                ParameterFilter = {
                    $Uri -like 'https://ws.audioscrobbler.com/2.0*'
                }
            }
            Assert-MockCalled @amParams
        }

        It 'Should throw when an error is returned in the response' {
            Mock Invoke-LFMApiUri { throw 'Error' } -ModuleName 'PowerLFM'

            { Get-LFMAlbumTag -Album Album -Artist Artist } | Should -Throw 'Error'
        }
    }
}
