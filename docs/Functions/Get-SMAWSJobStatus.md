# Get-SMAWSJobStatus

## SYNOPSIS

returns the Status of a Job

## SYNTAX

```powershell
Get-SMAWSJobStatus [-WebServiceEndpoint] <String> [[-Port] <Int32>] [[-Credential] <PSCredential>] [-JobID] <String> [<CommonParameters>]
```

## DESCRIPTION

returns the Status of a Job and the Output

## PARAMETERS

### -WebServiceEndpoint &lt;String&gt;

defines the https-address of the web service endpoint

```
Required?                    true
Position?                    1
Default value
Accept pipeline input?       false
Accept wildcard characters?  false
```

### -Port &lt;Int32&gt;

defines the TCP port of the web service endpoint.

this parameter is not mandatory, the default value is 9090

```
Required?                    false
Position?                    2
Default value                9090
Accept pipeline input?       false
Accept wildcard characters?  false
```

### -Credential &lt;PSCredential&gt;

defines credentials to access the SMA web service

```
Required?                    false
Position?                    3
Default value
Accept pipeline input?       false
Accept wildcard characters?  false
```

### -JobID &lt;String&gt;

define the id off the job to check

```
Required?                    true
Position?                    4
Default value
Accept pipeline input?       false
Accept wildcard characters?  false
```

## OUTPUTS

System.Object

## EXAMPLES

### EXAMPLE 1

```powershell
$JobStatus = get-SMAWSJobStatus -WebServiceEndpoint $WebServiceEndpoint -Port $Port -JobID $JobId
$JobStatus.Status
$JobStatus.Output
```


