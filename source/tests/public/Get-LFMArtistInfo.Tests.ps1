
Describe 'Get-LFMArtistInfo: Unit' -Tag Unit {

    BeforeAll {
        . $PSScriptRoot\..\RequestRecorder.ps1

        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMArtistInfo'.ArtistInfo

        $module = @{ ModuleName = 'PowerLFM' }

        $originalConfig = InModuleScope @module { $script:LFMConfig }

        InModuleScope @module {
            $script:LFMConfig = [pscustomobject] @{
                ApiKey       = 'ApiKeyValue'
                SessionKey   = 'SessionKeyValue'
                SharedSecret = 'SharedSecretValue'
            }
        }
    }

    AfterAll {
        InModuleScope @module -Parameters @{ Config = $originalConfig } {
            param ($Config)
            $script:LFMConfig = $Config
        }
    }

    BeforeEach {
        Register-LFMFakeRestMethod -Response $contextMock
    }

    Context 'Input' {

        It 'Should throw when artist is null' {
            { Get-LFMArtistInfo -Artist $null } | Should -Throw
        }
    }

    Context 'Request' {

        It 'Sends artist.getInfo as an unsigned GET' {
            $null = Get-LFMArtistInfo -Artist 'Opeth'

            $request = Get-LFMRecordedRequest
            $request.Method | Should -Be 'artist.getInfo'
            $request.HttpMethod | Should -Be 'Get'
            $request.Parameters.ContainsKey('api_sig') | Should -BeFalse
            $request.Parameters.ContainsKey('sk') | Should -BeFalse
        }

        It 'Sends the artist' {
            $null = Get-LFMArtistInfo -Artist 'Opeth'

            $request = Get-LFMRecordedRequest
            $request.Parameters['artist'] | Should -Be 'Opeth'
        }

        It 'Sends the id as mbid' {
            $id = New-Guid
            $null = Get-LFMArtistInfo -Id $id

            (Get-LFMRecordedRequest).Parameters['mbid'] | Should -Be $id.ToString()
        }

        It 'Sends the user name as username' {
            $null = Get-LFMArtistInfo -Artist 'Opeth' -UserName 'camusicjunkie'

            $request = Get-LFMRecordedRequest
            $request.Parameters['username'] | Should -Be 'camusicjunkie'
            $request.Parameters.ContainsKey('user') | Should -BeFalse
        }

        It 'Sends autocorrect as 1' {
            $null = Get-LFMArtistInfo -Artist 'Opeth' -AutoCorrect

            (Get-LFMRecordedRequest).Parameters['autocorrect'] | Should -Be '1'
        }

        It 'Sends one request per piped object' {
            $null = @(
                [pscustomobject] @{ Artist = 'Artist1' }
                [pscustomobject] @{ Artist = 'Artist2' }
            ) | Get-LFMArtistInfo

            $requests = @(Get-LFMRecordedRequest)
            $requests.Count | Should -Be 2
            $requests[1].Parameters['artist'] | Should -Be 'Artist2'
        }
    }

    Context 'Output' {

        BeforeAll {
            Register-LFMFakeRestMethod -Response $contextMock
            $output = Get-LFMArtistInfo -Artist Artist
        }

        It 'Should return the correct artist name' {
            $output.Artist | Should -Be $contextMock.Artist.Name
        }

        It 'Should return the correct artist id' {
            $output.Id | Should -Be $contextMock.Artist.Mbid
        }

        It 'Should return the correct artist url' {
            $output.Url | Should -Be $contextMock.Artist.Url
        }

        It 'Should return the correct listener count' {
            $output.Listeners | Should -BeOfType [int]
            $output.Listeners | Should -Be $contextMock.Artist.Stats.Listeners
        }

        It 'Should return the correct play count' {
            $output.PlayCount | Should -BeOfType [int]
            $output.PlayCount | Should -Be $contextMock.Artist.Stats.PlayCount
        }

        It 'Should return the correct first similar artist name' {
            $output.SimilarArtists[0].Artist | Should -Be $contextMock.Artist.Similar.Artist[0].Name
        }

        It 'Should return the correct second similar artist url' {
            $output.SimilarArtists[1].Url | Should -Be $contextMock.Artist.Similar.Artist[1].Url
        }

        It 'Artist should have two similar artists' {
            $output.SimilarArtists | Should -HaveCount 2
        }

        It 'Should return the correct first tag name' {
            $output.Tags[0].Tag | Should -Be $contextMock.Artist.Tags.Tag[0].Name
        }

        It 'Should return the correct second tag url' {
            $output.Tags[1].Url | Should -Be $contextMock.Artist.Tags.Tag[1].Url
        }

        It 'Artist should have two tags' {
            $output.Tags | Should -HaveCount 2
        }

        It 'Should return the correct artist biography summary' {
            $output.Summary | Should -BeExactly $contextMock.Artist.Bio.Summary
        }

        It "Artist should have OnTour of 'Yes' when ontour is 1" {
            $output.OnTour | Should -Be 'Yes'
        }

        It 'Should return the correct user play count' {
            $output = Get-LFMArtistInfo -Artist Artist -UserName camusicjunkie
            $output.UserPlayCount | Should -Be $contextMock.Artist.Stats.UserPlayCount
        }

        It 'Artist should have two similar artists when id parameter is used' {
            $output = Get-LFMArtistInfo -Id (New-Guid)
            $output.SimilarArtists | Should -HaveCount 2
        }

        It 'Should throw when an error is returned in the response' {
            Register-LFMFakeRestMethod -Response ([pscustomobject] @{ error = 6; message = 'Not found' })

            { Get-LFMArtistInfo -Artist Artist } | Should -Throw '*Not found*'
        }
    }
}
