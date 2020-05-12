# get-SMAWSJobs

## SYNOPSIS

this function returns the Jobs

## SYNTAX

```powershell
get-SMAWSJobs [[-WebServiceEndpoint] <String>] [[-Port] <Int32>] [[-Credential] <PSCredential>] [[-RunbookName] <String>] [<CommonParameters>]
```

## DESCRIPTION

this function returns the Jobs

## PARAMETERS

### -WebServiceEndpoint &lt;String&gt;

defines the https-address of the web service endpoint

```
Required?                    false
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

### -RunbookName &lt;String&gt;

defines the job id for which the parameters should be returned

```
Required?                    false
Position?                    4
Default value
Accept pipeline input?       false
Accept wildcard characters?  false
```

## OUTPUTS

System.Object[]

## EXAMPLES

### EXAMPLE 1

```powershell
get-SMAWSJobs -WebServiceEndpoint $WebServiceEndpoint -Port $Port
```

### EXAMPLE 2

```powershell
get-SMAWSJobs -WebServiceEndpoint $WebServiceEndpoint -Port $Port -RunbookName $RunbookName
```


