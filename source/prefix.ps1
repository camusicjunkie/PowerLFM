using namespace System.Management.Automation
Import-LocalizedData -BindingVariable localizedData -FileName localizedData

New-Variable -Name baseUrl -Value 'https://ws.audioscrobbler.com/2.0'
