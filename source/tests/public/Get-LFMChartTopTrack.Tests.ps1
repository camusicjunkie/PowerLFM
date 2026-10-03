
Describe 'Get-LFMChartTopTrack: Unit' -Tag Unit {

    BeforeAll {
        . $PSScriptRoot\..\RequestRecorder.ps1

        $mocks = Get-Content -Path $PSScriptRoot\..\config\mocks.json | ConvertFrom-Json
        $contextMock = $mocks.'Get-LFMChartTopTrack'.ChartTopTrack

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

        It 'Should throw when limit is greater than 119' {
            { Get-LFMChartTopTrack -Limit 120 } | Should -Throw
        }
    }

    Context 'Request' {

        It 'Sends chart.getTopTracks as an unsigned GET' {
            $null = Get-LFMChartTopTrack -Limit 5 -Page 2

            $request = Get-LFMRecordedRequest
            $request.Method | Should -Be 'chart.getTopTracks'
            $request.HttpMethod | Should -Be 'Get'
            $request.Parameters.ContainsKey('api_sig') | Should -BeFalse
            $request.Parameters.ContainsKey('sk') | Should -BeFalse
        }

        It 'Sends the limit and page' {
            $null = Get-LFMChartTopTrack -Limit 5 -Page 2

            $request = Get-LFMRecordedRequest
            $request.Parameters['limit'] | Should -Be '5'
            $request.Parameters['page'] | Should -Be '2'
        }
    }

    Context 'Output' {

        BeforeAll {
            Register-LFMFakeRestMethod -Response $contextMock
            $output = Get-LFMChartTopTrack
        }

        It 'Should return the correct first top track name' {
            $output[0].Track | Should -Be $contextMock.Tracks.Track[0].Name
        }

        It 'Should return the correct first top track artist name' {
            $output[0].Artist | Should -Be $contextMock.Tracks.Track[0].Artist.Name
        }

        It 'Should return the correct first top track duration' {
            $output[0].Duration | Should -Be $contextMock.Tracks.Track[0].Duration
        }

        It 'Should return the correct first top track play count' {
            $output[0].PlayCount | Should -BeOfType [int]
            $output[0].PlayCount | Should -Be $contextMock.Tracks.Track[0].PlayCount
        }

        It 'Should return the correct second top track play count' {
            $output[1].PlayCount | Should -BeOfType [int]
            $output[1].PlayCount | Should -Be $contextMock.Tracks.Track[1].PlayCount
        }

        It 'Should return the correct second top track artist id' {
            $output[1].ArtistId | Should -Be $contextMock.Tracks.Track[1].Artist.Mbid
        }

        It 'Should return the correct second top track artist url' {
            $output[1].ArtistUrl | Should -Be $contextMock.Tracks.Track[1].Artist.Url
        }

        It 'Should return the correct second top track url' {
            $output[1].TrackUrl | Should -Be $contextMock.Tracks.Track[1].Url
        }

        It 'Chart should have two top tracks' {
            $output.Track | Should -HaveCount 2
        }

        It 'Should throw when an error is returned in the response' {
            Register-LFMFakeRestMethod -Response ([pscustomobject] @{ error = 6; message = 'Not found' })

            { Get-LFMChartTopTrack } | Should -Throw '*Not found*'
        }
    }
}
