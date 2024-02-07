# BeforeAll {
#     Remove-Module -Name PowerLFM -ErrorAction Ignore
#     Import-Module -Name $PSScriptRoot\..\PowerLFM\PowerLFM.psd1
# }


Describe 'Add-LFMArtistTag: Unit' -Tag Unit {

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

        It 'Should throw when artist is null' {
            { Add-LFMArtistTag -Artist $null } | Should -Throw
        }

        It 'Should throw when tag has more than 10 values' {
            { Add-LFMArtistTag -Artist Artist -Tag @(1..11) -Confirm:$false } | Should -Throw
        }

        It 'Should not throw when tag has 1 to 10 values' {
            { Add-LFMArtistTag -Artist Artist -Tag @(1..10) -Confirm:$false } | Should -Not -Throw
        }
    }

    Context 'Execution' {

        BeforeAll {
            Add-LFMArtistTag -Artist Artist -Tag Tag -Confirm:$false
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
                    $Method -eq 'artist.addTags'
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
            Add-LFMArtistTag -Artist Artist -Tag Tag -Confirm:$false

            $amParams = @{
                CommandName     = 'Invoke-LFMApiUri'
                ModuleName      = 'PowerLFM'
                Scope           = 'It'
                Exactly         = $true
                Times           = 1
                ParameterFilter = {
                    $Method -eq 'Post' -and
                    $Uri -like "$baseUrl*"
                }
            }
            Assert-MockCalled @amParams
        }

        It 'Should send proper output when -Whatif is used' {
            $output = Add-LFMArtistTag -Artist Artist -Tag Tag -Verbose 4>&1 -Confirm:$false
            $output | Should -Match 'Performing the operation "Adding artist tag: Tag" on target "Artist: Artist".'
        }

        It 'Should throw when an error is returned in the response' {
            Mock Invoke-LFMApiUri { throw 'Error' } -ModuleName 'PowerLFM'

            { Add-LFMArtistTag -Artist Artist -Tag Tag -Confirm:$false } | Should -Throw 'Error'
        }
    }
}
