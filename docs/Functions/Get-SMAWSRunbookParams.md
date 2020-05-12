# Get-SMAWSRunbookParams

## SYNOPSIS

returns all possible parameters for a runbook

## SYNTAX

```powershell
Get-SMAWSRunbookParams -WebServiceEndpoint <String> -Port <Int32> [-Credential <PSCredential>] [-RunbookName <String>] [<CommonParameters>]
```

## DESCRIPTION

returns one or more runbooks based on the parameters

## PARAMETERS

### -WebServiceEndpoint &lt;String&gt;

defines the https-address of the web service endpoint

```
Required?                    true
Position?                    named
Default value
Accept pipeline input?       false
Accept wildcard characters?  false
```

### -Port &lt;Int32&gt;

defines the TCP port of the web service endpoint.

this parameter is not mandatory, the default value is 9090

```
Required?                    true
Position?                    named
Default value                9090
Accept pipeline input?       false
Accept wildcard characters?  false
```

### -Credential &lt;PSCredential&gt;

defines credentials to access the SMA web service

```
Required?                    false
Position?                    named
Default value
Accept pipeline input?       false
Accept wildcard characters?  false
```

### -RunbookName &lt;String&gt;

defines the filter by the name of the runbook

this parameter is not mandatory. if not used, it will return all runbooks

```
Required?                    false
Position?                    named
Default value
Accept pipeline input?       false
Accept wildcard characters?  false
```

## OUTPUTS

System.Object[]

## EXAMPLES

### EXAMPLE 1

```powershell
Get-SMAWSRunbookParams -WebServiceEndpoint $WebServiceEndpoint -Port $Port -RunbookName $RunbookName
```


