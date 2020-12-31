BeforeAll {
    Remove-Module -Name PowerLFM -ErrorAction Ignore
    Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1
}

Describe 'Set-LFMTrackNowPlaying: Unit' -Tag Unit {

    BeforeDiscovery {
        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Set-LFMTrackNowPlaying'.TrackNowPlaying
    }

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
                    $Uri -like "$baseUrl*"
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
