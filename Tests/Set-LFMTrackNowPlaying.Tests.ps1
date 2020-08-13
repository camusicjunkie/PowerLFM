BeforeAll {
    Remove-Module -Name PowerLFM -ErrorAction Ignore
    Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1
}

Describe 'Set-LFMTrackNowPlaying: Interface' -Tag Interface {

    BeforeAll {
        $command = Get-Command -Name 'Set-LFMTrackNowPlaying'
    }

    It 'CmdletBinding should be declared' {
        $command.CmdletBinding | Should -BeTrue
    }

    It 'Should contain an output type of PowerLFM.Track.NowPlaying' {
        $command.OutputType.Name | Should -Be 'PowerLFM.Track.NowPlaying'
    }

    Context 'ParameterSetName __AllParameterSets' {

        It 'Should have a parameter set of __AllParameterSets' {
            $command.ParameterSets.Name | Should -Contain '__AllParameterSets'
        }

        BeforeAll {
            $parameterSet = $command.ParameterSets | Where-Object Name -EQ __AllParameterSets
        }

        Context 'Parameter [Track] attribute validation' {

            BeforeAll {
                $parameter = $parameterSet.Parameters | Where-Object Name -EQ Track
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
                $parameter = $parameterSet.Parameters | Where-Object Name -EQ Artist
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

        Context 'Parameter [Album] attribute validation' {

            BeforeAll {
                $parameter = $parameterSet.Parameters | Where-Object Name -EQ Album
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

            It 'ValueFromPipelineByPropertyName should be set to True' {
                $parameter.ValueFromPipelineByPropertyName | Should -BeTrue
            }

            It 'ValueFromRemainingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It 'Should have a position of 2' {
                $parameter.Position | Should -Be 2
            }
        }

        Context 'Parameter [Id] attribute validation' {

            BeforeAll {
                $parameter = $parameterSet.Parameters | Where-Object Name -EQ Id
            }

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It 'Should be of type System.Guid' {
                $parameter.ParameterType.ToString() | Should -Be System.Guid
            }

            It 'Mandatory should be set to False' {
                $parameter.IsMandatory | Should -BeFalse
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

            It 'Should have a position of 3' {
                $parameter.Position | Should -Be 3
            }
        }

        Context 'Parameter [Duration] attribute validation' {

            BeforeAll {
                $parameter = $parameterSet.Parameters | Where-Object Name -EQ Duration
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

            It 'ValueFromPipelineByPropertyName should be set to True' {
                $parameter.ValueFromPipelineByPropertyName | Should -BeTrue
            }

            It 'ValueFromRemainingArguments should be set to False' {
                $parameter.ValueFromRemainingArguments | Should -BeFalse
            }

            It 'Should have a position of 4' {
                $parameter.Position | Should -Be 4
            }
        }

        Context 'Parameter [PassThru] attribute validation' {

            BeforeAll {
                $parameter = $parameterSet.Parameters | Where-Object Name -EQ PassThru
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

Describe 'Set-LFMTrackNowPlaying: Unit' -Tag Unit {

    #region Discovery

    $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
    $contextMock = $mocks.'Set-LFMTrackNowPlaying'.TrackNowPlaying

    #endregion Discovery

    BeforeAll {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Set-LFMTrackNowPlaying'.TrackNowPlaying

        Mock Remove-CommonParameter {
            [hashtable] @{
                Track  = 'Track'
                Artist = 'Artist'
            }
        } -ModuleName 'PowerLFM'
        Mock ConvertTo-LFMParameter -ModuleName 'PowerLFM'
        Mock Get-LFMSignature -ModuleName 'PowerLFM'
        Mock New-LFMApiQuery -ModuleName 'PowerLFM'
        Mock Invoke-LFMApiUri -ModuleName 'PowerLFM'
        Mock Get-LFMIgnoredMessage { @{ Code = 0 } } -ModuleName 'PowerLFM'
    }

    Context 'Input' {

        It 'Should throw when artist is null' {
            { Set-LFMTrackNowPlaying -Artist $null } | Should -Throw
        }

        It 'Should throw when track is null' {
            { Set-LFMTrackNowPlaying -Track $null } | Should -Throw
        }
    }

    Context 'Execution' {

        BeforeAll {
            Set-LFMTrackNowPlaying -Artist Artist -Track Track
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

        It 'Should create a signature from the parameters passed in' {
            $siParams = @{
                CommandName     = 'Get-LFMSignature'
                ModuleName      = 'PowerLFM'
                Scope           = 'Context'
                Exactly         = $true
                Times           = 1
                ParameterFilter = {
                    $Artist -eq 'Artist' -and
                    $Track -eq 'Track' -and
                    $Method -eq 'track.updateNowPlaying'
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

        It 'Should check to see if the response has not been filtered' {
            $siParams = @{
                CommandName     = 'Get-LFMIgnoredMessage'
                ModuleName      = 'PowerLFM'
                Scope           = 'Context'
                Exactly         = $true
                Times           = 1
                ParameterFilter = {
                    $Code -eq 0
                }
            }
            Should -Invoke @siParams
        }
    }

    Context 'Output' {

        It 'Should call the correct Last.fm post method' {
            Set-LFMTrackNowPlaying -Track Track -Artist Artist

            $siParams = @{
                CommandName     = 'Invoke-LFMApiUri'
                ModuleName      = 'PowerLFM'
                Exactly         = $true
                Times           = 1
                ParameterFilter = {
                    $Method -eq 'Post' -and
                    $Uri -like 'https://ws.audioscrobbler.com/2.0*'
                }
            }
            Should -Invoke @siParams
        }

        It 'Should send proper output when -Whatif is used' {
            $output = Set-LFMTrackNowPlaying -Artist Artist -Track Track -Verbose 4>&1
            $output[0] | Should -Match 'Performing the operation "Setting track to now playing" on target "Track: Track".'
        }

        It 'Should output an object when -PassThru is used' {
            Mock Invoke-LFMApiUri { $contextMock } -ModuleName 'PowerLFM'

            $output = Set-LFMTrackNowPlaying -Artist Artist -Track Track -PassThru
            $output.Artist | Should -Be $contextMock.NowPlaying.Artist.'#text'
            $output.Album | Should -Be $contextMock.NowPlaying.Album.'#text'
            $output.Track | Should -Be $contextMock.NowPlaying.Track.'#text'
        }

        It 'Should throw when ignored message code is 1' {
            Mock Get-LFMIgnoredMessage { @{ Code = 1; Message = 'Filtered message' } } -ModuleName 'PowerLFM'

            { Set-LFMTrackNowPlaying -Artist Artist -Track Track } | Should -Throw 'Request has been filtered because of bad meta data. Filtered message.'
        }

        It 'Should throw when an error is returned in the response' {
            Mock Invoke-LFMApiUri { throw 'Error' } -ModuleName 'PowerLFM'

            { Set-LFMTrackNowPlaying -Track Track -Artist Artist } | Should -Throw 'Error'
        }
    }
}
