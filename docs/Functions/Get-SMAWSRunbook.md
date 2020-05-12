# Get-SMAWSRunbook

## SYNOPSIS

returns one or more runbooks

## SYNTAX

```powershell
Get-SMAWSRunbook -WebServiceEndpoint <String> [-Port <Int32>] [-Credential <PSCredential>] [-RunbookType <String>] [<CommonParameters>]



Get-SMAWSRunbook -WebServiceEndpoint <String> [-Port <Int32>] [-Credential <PSCredential>] [-RunbookName <String>] [-RunbookType <String>] [<CommonParameters>]



Get-SMAWSRunbook -WebServiceEndpoint <String> [-Port <Int32>] [-Credential <PSCredential>] [-RunbookID <String>] [-RunbookType <String>] [<CommonParameters>]
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
Required?                    false
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

### -RunbookID &lt;String&gt;

defines the filter by the id of the runbook

this parameter is not mandatory. if not used, it will return all runbooks

```
Required?                    false
Position?                    named
Default value
Accept pipeline input?       false
Accept wildcard characters?  false
```

### -RunbookType &lt;String&gt;

defines the filter by type: PowerShellWorkflow or PowerShellScript

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
Get-SMAWSRunbook -WebServiceEndpoint $WebServiceEndpoint -Port $Port [-RunbookType 'PowerShellWorkflow' / 'PowerShellScript']
```

### EXAMPLE 2

```powershell
Get-SMAWSRunbook -WebServiceEndpoint $WebServiceEndpoint -Port $Port -RunbookName $RunbookName  [-RunbookType 'PowerShellWorkflow' / 'PowerShellScript']
```

### EXAMPLE 3

```powershell
Get-SMAWSRunbook -WebServiceEndpoint $WebServiceEndpoint -Port $Port -RunbookID $RunbookID  [-RunbookType 'PowerShellWorkflow' / 'PowerShellScript']
```


