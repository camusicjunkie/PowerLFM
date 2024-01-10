BeforeAll {
    Remove-Module -Name PowerLFM -ErrorAction Ignore
    Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1
}

Describe 'Set-LFMTrackUnlove: Unit' -Tag Unit {

    BeforeAll {
        Mock Remove-CommonParameter {
            [hashtable] @{
                Artist = 'Artist'
                Track  = 'Track'
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
            { Set-LFMTrackUnlove -Artist $null } | Should -Throw
        }

        It 'Should throw when track is null' {
            { Set-LFMTrackUnlove -Track $null } | Should -Throw
        }
    }

    Context 'Execution' {

        BeforeAll {
            Set-LFMTrackUnlove -Artist Artist -Track Track -Confirm:$false
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
                    $Method -eq 'track.unlove'
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
            Set-LFMTrackUnlove -Artist Artist -Track Track -Confirm:$false

            $siParams = @{
                CommandName     = 'Invoke-LFMApiUri'
                ModuleName      = 'PowerLFM'
                Exactly         = $true
                Times           = 1
                ParameterFilter = {
                    $Method -eq 'Post' -and
                    $Uri -like "$baseUrl*"
                }
            }
            Should -Invoke @siParams
        }

        It 'Should send proper output when -Whatif is used' {
            $output = Set-LFMTrackUnlove -Artist Artist -Track Track -Confirm:$false -Verbose 4>&1
            $output | Should -Match 'Performing the operation "Removing love" on target "Track: Track".'
        }

        It 'Should throw when an error is returned in the response' {
            Mock Invoke-LFMApiUri { throw 'Error' } -ModuleName 'PowerLFM'

            { Set-LFMTrackUnlove -Artist Artist -Track Track -Confirm:$false } | Should -Throw 'Error'
        }
    }
}
