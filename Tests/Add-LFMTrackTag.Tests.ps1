BeforeAll {
    Remove-Module -Name PowerLFM -ErrorAction Ignore
    Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1
}

Describe 'Add-LFMTrackTag: Interface' -Tag Interface {

    BeforeAll {
        $command = Get-Command -Name 'Add-LFMTrackTag'
    }

    It 'CmdletBinding should be declared' {
        $command.CmdletBinding | Should -BeTrue
    }

    Context 'ParameterSetName __AllParameterSets' {

        It 'Should have a parameter set of __AllParameterSets' {
            $command.ParameterSets.Name | Should -Contain '__AllParameterSets'
        }

        BeforeAll {
            $parameterSet = $command.ParameterSets | Where-Object Name -eq __AllParameterSets
        }

        Context 'Parameter [Track] attribute validation' {

            BeforeAll {
                $parameter = $parameterSet.Parameters | Where-Object Name -eq Track
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

        Context 'Parameter [Tag] attribute validation' {

            BeforeAll {
                $parameter = $parameterSet.Parameters | Where-Object Name -eq Tag
            }

            It 'Should not be null or empty' {
                $parameter | Should -Not -BeNullOrEmpty
            }

            It 'Should be of type System.String[]' {
                $parameter.ParameterType.ToString() | Should -Be System.String[]
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

            It 'Should have a position of 2' {
                $parameter.Position | Should -Be 2
            }
        }
    }
}

Describe 'Add-LFMTrackTag: Unit' -Tag Unit {

    BeforeAll {
        Mock Remove-CommonParameter {
            [hashtable] @{
                Track  = 'Track'
                Artist = 'Artist'
                Tag    = 'Tag'
            }
        } -ModuleName 'PowerLFM'
        Mock ConvertTo-LFMParameter -ModuleName 'PowerLFM'
        Mock Get-LFMSignature -ModuleName 'PowerLFM'
        Mock New-LFMApiQuery -ModuleName 'PowerLFM'
        Mock Invoke-LFMApiUri -ModuleName 'PowerLFM'
        Mock Get-LFMIgnoredMessage { @{ Code = 0 } } -ModuleName 'PowerLFM'
    }

    Context 'Input' {

        It 'Should throw when track is null' {
            { Add-LFMTrackTag -Track $null } | Should -Throw
        }

        It 'Should throw when tag has more than 10 values' {
            { Add-LFMTrackTag -Track Track -Artist Artist -Tag @(1..11) -Confirm:$false } | Should -Throw
        }

        It 'Should not throw when tag has 1 to 10 values' {
            { Add-LFMTrackTag -Track Track -Artist Artist -Tag @(1..10) -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Execution' {

        BeforeAll {
            Add-LFMTrackTag -Track Track -Artist Artist -Tag Tag -Confirm:$false
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
                    $Track -eq 'Track' -and
                    $Artist -eq 'Artist' -and
                    $Tag -eq 'Tag' -and
                    $Method -eq 'track.addTags'
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

        It 'Should call the correct Last.fm post method' {
            Add-LFMTrackTag -Track Track -Artist Artist -Tag Tag -Confirm:$false

            $siParams = @{
                CommandName     = 'Invoke-LFMApiUri'
                ModuleName      = 'PowerLFM'
                Scope           = 'It'
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
            $output = Add-LFMTrackTag -Track Track -Artist Artist -Tag Tag -Confirm:$false -Verbose 4>&1
            $output | Should -Match 'Performing the operation "Adding track tag: Tag" on target "Track: Track".'
        }

        It 'Should throw when an error is returned in the response' {
            Mock Invoke-LFMApiUri { throw 'Error' } -ModuleName 'PowerLFM'

            { Add-LFMTrackTag -Track Track -Artist Artist -Tag Tag -Confirm:$false } | Should -Throw 'Error'
        }
    }
}
