function Set-SMAWSCertificatePolicy {
    <#
        .SYNOPSIS
            sets the certificate policy

        .DESCRIPTION
            sets the certificate policy to accept all certificates

        .PARAMETER WebServiceEndPoint
            defines the https-address of the web service endpoint

            this parameter is mandatory

        .PARAMETER Port
            defines the TCP port of the web service endpoint.

            this parameter is not mandatory, the default value is 9090

        .PARAMETER Credential
            defines credentials to access the SMA web service

            this parameter is not mandatory

        .PARAMETER PolicyType
            defines the policy type

            you can use:
            - TrustAllCerts
            - Org

            this parameter is mandatory

        .EXAMPLE

    #>
    [OutputType([System.Object])]
    [CmdletBinding()]
    Param (
        [ValidateSet('TrustAllCerts', 'Org')]
        [string]$PolicyType = 'Org'
    )
    $function = $($MyInvocation.MyCommand.Name)
    Write-Verbose "Running $function"

    try {
        switch ( $PolicyType )
        {
            'Org' {
                if ( -not ( [string]::IsNullOrEmpty( $Script:oldCertificatePolicy ) ) ) {
                    [System.Net.ServicePointManager]::CertificatePolicy = $Script:oldCertificatePolicy
                }
            }
            'TrustAllCerts' {
                if ( [string]::IsNullOrEmpty( $Script:oldCertificatePolicy ) ) {
                    $Script:oldCertificatePolicy = [System.Net.ServicePointManager]::CertificatePolicy
                }

                try {
                    Add-Type @"
                        using System.Net;
                        using System.Security.Cryptography.X509Certificates;
                        public class TrustAllCertsPolicy : ICertificatePolicy {
                            public bool CheckValidationResult( ServicePoint srvPoint, X509Certificate certificate, WebRequest request, int certificateProblem ) {
                                return true;
                            }
                        }
"@
                }
                catch {
                }
                [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
            }
        }
        return $ret
    }
    catch {
        $ret = [PSCustomObject]@{
            Function   = $function
            Activity   = $($_.CategoryInfo).Activity
            Message    = $($_.Exception.Message)
            Category   = $($_.CategoryInfo).Category
            Exception  = $($_.Exception)
            TargetName = $($_.CategoryInfo).TargetName
            LineNumber = $null
            Line       = $null
        }
        if ( $_.InvocationInfo.ScriptLineNumber ) {
            $ret.LineNumber = $_.InvocationInfo.ScriptLineNumber
        }
        if ( $_.Exception.Line ) {
            $ret.Line = $_.Exception.Line
        }

        #don't forget to clear the error-object
        $error.Clear()
        throw $ret
    }
}
