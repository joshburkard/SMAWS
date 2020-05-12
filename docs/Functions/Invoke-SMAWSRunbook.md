# Invoke-SMAWSRunbook

## SYNOPSIS

Invokes a SMA runbook through the Web Service

## SYNTAX

```powershell
Invoke-SMAWSRunbook [-WebServiceEndpoint] <String> [[-Port] <Int32>] [-RunbookName] <String> [[-Params] <Object>] [[-Credential] <PSCredential>] [-wait] [[-timeout] <Int32>]

[<CommonParameters>]
```

## DESCRIPTION

Invokes a SMA runbook through the Web Service

## PARAMETERS

### -WebServiceEndpoint &lt;String&gt;

defines the https-address of the web service endpoint

this parameter is mandatory

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

### -RunbookName &lt;String&gt;

defines the filter by the name of the runbook

this parameter is mandatory

```
Required?                    true
Position?                    3
Default value
Accept pipeline input?       false
Accept wildcard characters?  false
```

### -Params &lt;Object&gt;

this parameter defines the parameters which should be submited to the runbook

this parameter is not mandatory

```
Required?                    false
Position?                    4
Default value
Accept pipeline input?       false
Accept wildcard characters?  false
```

### -Credential &lt;PSCredential&gt;

defines credentials to access the SMA web service

this parameter is not mandatory

```
Required?                    false
Position?                    5
Default value
Accept pipeline input?       false
Accept wildcard characters?  false
```

### -wait &lt;SwitchParameter&gt;

if this switch parameter is set, the function will wait for the finish of the runbook

```
Required?                    false
Position?                    named
Default value                False
Accept pipeline input?       false
Accept wildcard characters?  false
```

### -timeout &lt;Int32&gt;

this defines how long the function should wait for a result

this parameter is not mandatory, the default value is 300 seconds

```
Required?                    false
Position?                    6
Default value                300
Accept pipeline input?       false
Accept wildcard characters?  false
```

## OUTPUTS

System.Management.Automation.PSObject

## EXAMPLES

### EXAMPLE 1

```powershell
# Example without params to submit

[string]$WebServiceEndpoint = 'server.domain.fqdn'
[int]$Port = 9090
$Credential = New-Object System.Management.Automation.PSCredential ( 'user@domain.fqdn', ( ConvertTo-SecureString 'somePassword' -AsPlainText -Force ) )
[string]$RunbookName = 'SA0-ALL-IMP-SCCM-AddNewDevice'

$SMAConnection = @{
    WebServiceEndpoint = $WebServiceEndpoint
    Port               = $Port
    Credential         = $Credential
}

Invoke-SMAWSRunbook @SMAConnection -RunbookName 'Test'
```

### EXAMPLE 2

```powershell
# Example with params to submit

$parameters = @{
    A = 'Test A'                              # String value
    B = 25                                    # Integer value
    C = @( 'Test B', 44 )                     # Array value
    D = 'true'                                # SwitchParameter must be set like a string
    E = '{"Name1":"Value1","Name2":"Value2"}' # JSON
}

Invoke-SMAWSRunbook @SMAConnection -RunbookName 'Test' -params $parameters
```

### EXAMPLE 3

```powershell
# transfeer a file content to Runbook parameter 'FileContent'

$FileContent = Get-Content -Path $FileName -Raw
$Bytes = [System.Text.Encoding]::Unicode.GetBytes($FileContent)
$EncodedText =[Convert]::ToBase64String($Bytes)

$parameters = @{
    FileContent = $EncodedText
}

Invoke-SMAWSRunbook @SMAConnection -RunbookName 'Test' -params $parameters
```


