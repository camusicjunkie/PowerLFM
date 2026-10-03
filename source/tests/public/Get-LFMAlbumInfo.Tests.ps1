Describe 'Get-LFMAlbumInfo: Unit' -Tag Unit {

    BeforeAll {
        . $PSScriptRoot\..\RequestRecorder.ps1

        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMAlbumInfo'.AlbumInfo

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

        It 'Should throw when album is null' {
            { Get-LFMAlbumInfo -Album $null } | Should -Throw
        }
    }

    Context 'Request' {

        It 'Sends album.getInfo as an unsigned GET' {
            $null = Get-LFMAlbumInfo -Album 'Blackwater Park' -Artist 'Opeth'

            $request = Get-LFMRecordedRequest
            $request.Method | Should -Be 'album.getInfo'
            $request.HttpMethod | Should -Be 'Get'
            $request.Parameters.ContainsKey('api_sig') | Should -BeFalse
            $request.Parameters.ContainsKey('sk') | Should -BeFalse
        }

        It 'Sends the album and artist' {
            $null = Get-LFMAlbumInfo -Album 'Blackwater Park' -Artist 'Opeth'

            $request = Get-LFMRecordedRequest
            $request.Parameters['album'] | Should -Be 'Blackwater Park'
            $request.Parameters['artist'] | Should -Be 'Opeth'
        }

        It 'Sends the id as mbid' {
            $id = New-Guid
            $null = Get-LFMAlbumInfo -Id $id

            (Get-LFMRecordedRequest).Parameters['mbid'] | Should -Be $id.ToString()
        }

        It 'Sends the user name as username' {
            $null = Get-LFMAlbumInfo -Album 'Blackwater Park' -Artist 'Opeth' -UserName 'camusicjunkie'

            $request = Get-LFMRecordedRequest
            $request.Parameters['username'] | Should -Be 'camusicjunkie'
            $request.Parameters.ContainsKey('user') | Should -BeFalse
        }

        It 'Sends autocorrect as 1' {
            $null = Get-LFMAlbumInfo -Album 'Blackwater Park' -Artist 'Opeth' -AutoCorrect

            (Get-LFMRecordedRequest).Parameters['autocorrect'] | Should -Be '1'
        }

        It 'Sends one request per piped object' {
            $null = @(
                [pscustomobject] @{ Album = 'Album1'; Artist = 'Artist1' }
                [pscustomobject] @{ Album = 'Album2'; Artist = 'Artist2' }
            ) | Get-LFMAlbumInfo

            $requests = @(Get-LFMRecordedRequest)
            $requests.Count | Should -Be 2
            $requests[1].Parameters['album'] | Should -Be 'Album2'
        }
    }

    Context 'Output' {

        BeforeAll {
            Register-LFMFakeRestMethod -Response $contextMock
            $output = Get-LFMAlbumInfo -Album Album -Artist Artist
        }

        It 'Should return the correct album name' {
            $output.Album | Should -Be $contextMock.Album.Name
        }

        It 'Should return the correct artist name' {
            $output.Artist | Should -Be $contextMock.Album.Artist
        }

        It 'Should return the correct album id' {
            $output.Id | Should -Be $contextMock.Album.Mbid
        }

        It 'Should return the correct album url' {
            $output.Url | Should -Be $contextMock.Album.Url
        }

        It 'Should return the correct listener count' {
            $output.Listeners | Should -BeOfType [int]
            $output.Listeners | Should -Be $contextMock.Album.Listeners
        }

        It 'Should return the correct play count' {
            $output.PlayCount | Should -BeOfType [int]
            $output.PlayCount | Should -Be $contextMock.Album.PlayCount
        }

        It 'Should return the correct first track name' {
            $output.Tracks[0].Track | Should -Be $contextMock.Album.Tracks.Track[0].Name
        }

        It 'Should return the correct second track duration' {
            $output.Tracks[1].Duration | Should -Be $contextMock.Album.Tracks.Track[1].Duration
        }

        It 'Album should have two tracks' {
            $output.Tracks | Should -HaveCount 2
        }

        It 'Should return the correct first tag name' {
            $output.Tags[0].Tag | Should -Be $contextMock.Album.Tags.Tag[0].Name
        }

        It 'Should return the correct second tag url' {
            $output.Tags[1].Url | Should -Be $contextMock.Album.Tags.Tag[1].Url
        }

        It 'Album should have two tags' {
            $output.Tags | Should -HaveCount 2
        }

        It 'Should return the correct album summary' {
            $output.Summary | Should -BeExactly $contextMock.Album.Wiki.Summary
        }

        It 'Should return the correct user play count' {
            $output = Get-LFMAlbumInfo -Artist Artist -Album Album -UserName camusicjunkie
            $output.UserPlayCount | Should -Be $contextMock.Album.UserPlayCount
        }

        It 'Album should have two tracks when id parameter is used' {
            $output = Get-LFMAlbumInfo -Id (New-Guid)
            $output.Tracks | Should -HaveCount 2
        }

        It 'Should throw when an error is returned in the response' {
            Register-LFMFakeRestMethod -Response ([pscustomobject] @{ error = 6; message = 'Album not found' })

            { Get-LFMAlbumInfo -Album Album -Artist Artist } | Should -Throw '*Album not found*'
        }
    }
}
