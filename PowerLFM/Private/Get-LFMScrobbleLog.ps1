function Get-LFMScrobbleLog {
    [CmdletBinding()]
    param ()

    if (-not (Test-LFMScrobbleLog)) {
        $logPath = "$env:APPDATA\WindowsPowerShell\PowerLFM"
        $null = New-Item $logPath -ItemType Directory -ErrorAction SilentlyContinue
        $null = New-Item $logPath -Name 'ScrobbleLog.csv' -ItemType File -ErrorAction SilentlyContinue
    }

    Import-Csv -Path "$logPath\ScrobbleLog.csv"
}
