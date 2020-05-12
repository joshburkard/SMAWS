# Get-SMAWSEntries

## SYNOPSIS

this function get entries from the SMA WebService

## SYNTAX

```powershell
Get-SMAWSEntries [[-WebServiceEndpoint] <String>] [[-Port] <Int32>] [[-Credential] <PSCredential>] [[-EntryType] <String>] [<CommonParameters>]
```

## DESCRIPTION

this function get entries from the SMA WebService

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

### -EntryType &lt;String&gt;

defines the type of the entries to return

this string parameter is mandatory

```
Required?                    false
Position?                    4
Default value                Runbooks
Accept pipeline input?       false
Accept wildcard characters?  false

Valid Values:
- Jobs
- Runbooks
- RunbookVersions
- JobContexts
- JobParameters
- Schedules
- Modules
- ConnectionFields
- ConnectionFieldValues
- Connections
- ConnectionTypes
- Variables
- Credentials
- Certificates
- Activities
- ActivityParameterSets
- ActivityParameters
- ActivityOutputTypes
- RunbookParameters
- Statistics
- AdminConfigurations
- Deployment
```

## OUTPUTS

System.Object

## EXAMPLES

### EXAMPLE 1

```powershell
Get-SMAWSEntries -WebServiceEndpoint $WebServiceEndpoint -Port $Port -EntryType Runbooks
```


