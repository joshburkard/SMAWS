# Get-SMAWSJobParams

## SYNOPSIS

this function returns the params submited to an SMA Job

## SYNTAX

```powershell
Get-SMAWSJobParams [-WebServiceEndpoint] <String> [[-Port] <Int32>] [[-Credential] <PSCredential>] [-JobID] <String> [<CommonParameters>]
```

## DESCRIPTION

this function returns the params submited to an SMA Job

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

defines the job id for which the parameters should be returned

```
Required?                    true
Position?                    4
Default value                8d708a20-ccc5-4e8e-9d3e-7a69f7991651
Accept pipeline input?       false
Accept wildcard characters?  false
```

## OUTPUTS

System.Object

## EXAMPLES

### EXAMPLE 1

```powershell
get-SMAWSJobParams -WebServiceEndpoint $WebServiceEndpoint -Port $Port -JobID $JobId
```


