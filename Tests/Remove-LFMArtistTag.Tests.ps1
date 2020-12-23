BeforeAll {
    Remove-Module -Name PowerLFM -ErrorAction Ignore
    Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1
}

Describe 'Remove-LFMArtistTag: Unit' -Tag Unit {

    BeforeAll {
        Mock Remove-CommonParameter {
            [hashtable] @{
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

        It 'Should throw when album is null' {
            { Remove-LFMArtistTag -Album $null } | Should -Throw
        }

        It 'Should throw when tag has more than 1 value' {
            { Remove-LFMArtistTag -Artist Artist -Tag @(1..2) } | Should -Throw
        }
    }

    Context 'Execution' {

        BeforeAll {
            Remove-LFMArtistTag -Artist Artist -Tag Tag -Confirm:$false
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
                    $Tag -eq 'Tag' -and
                    $Method -eq 'artist.removeTag'
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
            Remove-LFMArtistTag -Artist Artist -Tag Tag -Confirm:$false

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
            $output = Remove-LFMArtistTag -Artist Artist -Tag Tag -Confirm:$false -Verbose 4>&1
            $output | Should -Match 'Performing the operation "Removing artist tag: Tag" on target "Artist: Artist".'
        }

        It 'Should throw when an error is returned in the response' {
            Mock Invoke-LFMApiUri { throw 'Error' } -ModuleName 'PowerLFM'

            { Remove-LFMAlbumTag -Album Album -Artist Artist -Tag Tag -Confirm:$false } | Should -Throw 'Error'
        }
    }
}
