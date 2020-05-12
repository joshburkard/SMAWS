Import-Module .\SMAWS\SMAWS.psm1 -Force 
# Import-Module Pester -MinimumVersion '4.6.0'

Set-SMAWSCertificatePolicy -PolicyType TrustAllCerts

$SMAConnection = @{
    WebServiceEndPoint = $WebServiceEndpoint
    Port = 9090
}

# $SMAConnection

Describe "Invoke-SMAWSRunbook" {
    Context "Synopsis" {
        $FunctionHelp = Get-help -Name Invoke-SMAWSRunbook -Full

        it "Description shouldn't be empty" {
            ( -not ( [string]::IsNullOrEmpty(  $FunctionHelp.Description.Text ) ) ) | should -be $true
        }
        $parameter = @( $FunctionHelp.parameters.parameter )[0]
        foreach ( $parameter in $FunctionHelp.parameters.parameter ) {
            it "parameter $( $parameter.name ) should have a description" {
                ( -not ( [string]::IsNullOrEmpty( $parameter.Description.Text ) ) ) | should -be $true
            }
        }
    }

    Context "only with mandatory parameters" {
        it "should not throw" {
            { $global:res = Invoke-SMAWSRunbook @SMAConnection -RunbookName 'Test' } | should not throw
        }
        it "Status = 'started'" {
            $res.Status | should be 'started'
        }
        it "JobID is not empty" {
            [boolean]$res.JobID | should be $true
        }
        it "Output is empty" {
            [boolean]$res.Output | should be $false
        }
    }
    Context "with parameter -wait" {
        it "should not throw" {
            { $global:res = Invoke-SMAWSRunbook @SMAConnection -RunbookName 'Test' -wait } | should not throw
        }
        it "Status = 'Completed'" {
            $res.Status | should be 'Completed'
        }
        it "JobID is not empty" {
            [boolean]$res.JobID | should be $true
        }
        it "Output is not empty" {
            [boolean]$res.Output | should be $true
        }
    }
    Context "with parameters" {
        $parameters = @{
            FQDN = [System.Net.DNS]::GetHostByName( $env:COMPUTERNAME ).HostName
        }
        it "should not throw" {
            { $global:res = Invoke-SMAWSRunbook @SMAConnection -RunbookName 'Test' -Params $parameters } | should not throw
        }
        it "Status = 'started'" {
            $res.Status | should be 'started'
        }
        it "JobID is not empty" {
            [boolean]$res.JobID | should be $true
        }
        it "Output is empty" {
            [boolean]$res.Output | should be $false
        }
    }
}

# Set-SMAWSCertificatePolicy -PolicyType Org