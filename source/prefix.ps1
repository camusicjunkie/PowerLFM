using namespace System.Management.Automation
Import-LocalizedData -BindingVariable localizedData -FileName localizedData

New-Variable -Name baseUrl -Value 'https://ws.audioscrobbler.com/2.0'
New-Variable -Name scrobbleQueueVersion -Value 1
New-Variable -Name scrobbleQueueBatchSize -Value 50
New-Variable -Name scrobbleQueueWarningThreshold -Value 1000
