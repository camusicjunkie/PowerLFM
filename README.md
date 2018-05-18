# PowerLFM
PowerShell module to leverage the Last.fm API

To start you will need to generate a token which will be used to create a session key.

$session = Request-LFMToken -ApiKey $ApiKey -SharedSecret $SharedSecret | Request-LFMSession
