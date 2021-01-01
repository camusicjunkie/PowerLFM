function Test-LFMScrobbleLog {
    param ()

    Test-Path -Path "$env:APPDATA\WindowsPowerShell\PowerLFM\ScrobbleLog.csv" -ErrorAction Stop
}
