Describe 'Invoke-LFMApiUri: Unit' -Tag Unit {

    BeforeAll {
        $module = @{ ModuleName = 'PowerLFM' }
    }

    Context 'Success' {

        It 'Returns the response when the request succeeds' {
            $result = InModuleScope @module {
                Mock Invoke-RestMethod { [pscustomobject] @{ Artist = 'Artist' } }
                Invoke-LFMApiUri -Uri 'https://ws.audioscrobbler.com/2.0/?method=track.scrobble'
            }
            $result.Artist | Should -Be 'Artist'
        }
    }

    Context 'Error classification' {

        It 'Throws PowerLFM.ResourceNotFound when Last.fm returns an error object' {
            $errorRecord = InModuleScope @module {
                Mock Invoke-RestMethod {
                    [pscustomobject] @{ Error = 6; Message = 'Album not found' }
                }
                try { Invoke-LFMApiUri -Uri 'https://ws.audioscrobbler.com/2.0/' } catch { $_ }
            }
            $errorRecord.FullyQualifiedErrorId | Should -BeLike 'PowerLFM.ResourceNotFound*'
        }

        It 'Throws PowerLFM.WebResponseException when Last.fm returns an error body' {
            $errorRecord = InModuleScope @module {
                Mock Invoke-RestMethod {
                    $record = [ErrorRecord]::new(
                        [Exception]::new('Bad request'),
                        'Whatever',
                        'InvalidOperation',
                        $null
                    )
                    $record.ErrorDetails = '{ "error": 10, "message": "Invalid API key" }'
                    throw $record
                }
                try { Invoke-LFMApiUri -Uri 'https://ws.audioscrobbler.com/2.0/' } catch { $_ }
            }
            $errorRecord.FullyQualifiedErrorId | Should -BeLike 'PowerLFM.WebResponseException*'
        }

        It 'Throws PowerLFM.NetworkUnavailable when the host cannot be resolved' {
            $errorRecord = InModuleScope @module {
                Mock Invoke-RestMethod {
                    throw [Net.WebException]::new(
                        'The remote name could not be resolved.',
                        [Net.WebExceptionStatus]::NameResolutionFailure
                    )
                }
                try { Invoke-LFMApiUri -Uri 'https://ws.audioscrobbler.com/2.0/' } catch { $_ }
            }
            $errorRecord.FullyQualifiedErrorId | Should -BeLike 'PowerLFM.NetworkUnavailable*'
            $errorRecord.CategoryInfo.Category | Should -Be 'ConnectionError'
        }

        It 'Throws PowerLFM.NetworkUnavailable when the connection is refused' {
            $errorRecord = InModuleScope @module {
                Mock Invoke-RestMethod {
                    throw [Net.WebException]::new(
                        'Unable to connect to the remote server.',
                        [Net.WebExceptionStatus]::ConnectFailure
                    )
                }
                try { Invoke-LFMApiUri -Uri 'https://ws.audioscrobbler.com/2.0/' } catch { $_ }
            }
            $errorRecord.FullyQualifiedErrorId | Should -BeLike 'PowerLFM.NetworkUnavailable*'
        }

        It 'Throws PowerLFM.NetworkUnavailable when the request never reached Last.fm' -Skip:($PSVersionTable.PSVersion.Major -lt 6) {
            $errorRecord = InModuleScope @module {
                Mock Invoke-RestMethod {
                    throw [Net.Http.HttpRequestException]::new(
                        'No such host is known.',
                        [Net.Sockets.SocketException]::new(11001)
                    )
                }
                try { Invoke-LFMApiUri -Uri 'https://ws.audioscrobbler.com/2.0/' } catch { $_ }
            }
            $errorRecord.FullyQualifiedErrorId | Should -BeLike 'PowerLFM.NetworkUnavailable*'
        }

        It 'Does not classify an HTTP status failure as a network failure' -Skip:($PSVersionTable.PSVersion.Major -lt 6) {
            $errorRecord = InModuleScope @module {
                Mock Invoke-RestMethod {
                    $record = [ErrorRecord]::new(
                        [Microsoft.PowerShell.Commands.HttpResponseException]::new(
                            'Response status code does not indicate success: 503 (Service Unavailable).',
                            [Net.Http.HttpResponseMessage]::new(503)
                        ),
                        'WebCmdletWebResponseException',
                        'InvalidOperation',
                        $null
                    )
                    throw $record
                }
                try { Invoke-LFMApiUri -Uri 'https://ws.audioscrobbler.com/2.0/' } catch { $_ }
            }
            $errorRecord.FullyQualifiedErrorId | Should -Not -BeLike 'PowerLFM.NetworkUnavailable*'
        }
    }
}
