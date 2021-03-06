# powershell module SMAWS

this powershell module allows to manage Microsoft SMA (Service Management Automation) through the SMA web service.

![Build status](https://ci.appveyor.com/api/projects/status/xyetybo7i24oja7s/branch/master?svg=true)

## Prerequisites

this module works with Windows PowerShell and with PowerShell (Core). it was tested with Windows 2019, 2012 R2 and Ubuntu 1604.

this prerequisites must be fullfiled:

- the network communication to the SMA webservice (normaly TCP port 9090) must be open
- The used security protocol type must be allowed, see example below
- the certificate of the webservice should be trusted
- proxy should be disabled, see example below
- Windows Powershell 5.1 or PowerShell (Core) 6.0

## Help

for the help see the [help files](https://smaws.readthedocs.io/en/latest/)

## Example

```powershell
Import-Module SMAWS

# allow differnt SSL / TLS protocols
[Net.ServicePointManager]::SecurityProtocol = `
    [Net.SecurityProtocolType]::Tls12,
    [Net.SecurityProtocolType]::Tls11,
    [Net.SecurityProtocolType]::Tls,
    [Net.SecurityProtocolType]::Ssl3 ;

# Trust all certificates
Set-SMAWSCertificatePolicy -PolicyType TrustAllCerts

# bypass proxy
$proxy = new-object System.Net.WebProxy
[system.net.webrequest]::defaultwebproxy = $proxy

$Credential = New-Object System.Management.Automation.PSCredential ( 'user@domain.fqdn', ( ConvertTo-SecureString 'somePassword' -AsPlainText -Force ) )
$SMAConnection = @{
    WebServiceEndPoint = 'server.domain.fqdn'
    Port = 9090
    Credential = $Credential
}

$parameters = @{
    A = 'Test A'            # String value
    B = 25                  # Integer value
    C = @( 'Test B', 44 )   # Array value
}

$res = Invoke-SMAWSRunbook @SMAConnection -RunbookName 'Test' -params $parameters -wait

# reset certificate trust to origin setting
Set-SMAWSCertificatePolicy -PolicyType Org
```
