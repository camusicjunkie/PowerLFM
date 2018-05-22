Function Convert-UnixTime {
    <#
.Synopsis
Convert a unixtime value to a datetime value
.Description
Convert a unixtime value to a more meaningful datetime value. The default behavior is to convert to local time, including any daylight saving time offset. Or you can view the time in GMT.
.Parameter GMT
Don't convert to local time.
.Example
PS C:\> Convert-UnixTime 1426582884.043993
 
Tuesday, March 17, 2015 5:01:24 AM
#>
    [cmdletbinding()]
    Param(
        [Parameter(Position = 0, Mandatory,
                   HelpMessage = "Enter a unixtime value",
                   ValueFromPipeline)]
        [ValidateNotNullorEmpty()]
        [double] $UnixTime,
        [switch] $GMT
    )
 
    Begin {
        Write-Verbose "Starting $($MyInvocation.Mycommand)"
        #define universal starting time
        [datetime]$utc = "1/1/1970"
 
        #test for Daylight Saving Time
        Write-Verbose "Checking DaylightSavingTime"
        $dst = Get-Ciminstance -ClassName Win32_Computersystem -filter "DaylightInEffect = 'True'"
 
    } #begin
 
    Process {
        Write-Verbose "Processing $UnixTime"
        #add the unixtime value which should be the number of
        #seconds since 1/1/1970.
        $gmtTime = $utc.AddSeconds($UnixTime)
 
        if ($gmt) {
            #display default time which should be GMT if
            #user used -GMT parameter
            Write-verbose "GMT"
            $gmtTime
        }
        else {
            #otherwise convert to the local time zone
            Write-Verbose "Converting the $gmtTime to local time zone"
 
            #get time zone information from WMI
            $tz = Get-CimInstance -ClassName Win32_TimeZone
 
            #the bias is the number of minutes offset from GMT
            Write-Verbose "Timezone offset = $($tz.Bias)"
            #Add the necessary number of minutes to convert
            #to the local time.
            $local = $gmtTime.AddMinutes($tz.bias)
            if ($dst) {
                Write-Verbose "DST in effect with bias = $($tz.daylightbias)"
                $local.AddMinutes( - ($tz.DaylightBias))
            }
            else {
                #write the local time
                $local
            }
        }
    } #process
 
    End {
        Write-Verbose "Ending $($MyInvocation.Mycommand)"
    } #end
 
} #close Convert-unixtime function