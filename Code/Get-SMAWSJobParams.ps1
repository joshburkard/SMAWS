function Get-SMAWSJobParams {
    <#
        .SYNOPSIS
            this function returns the params submited to an SMA Job

        .Description
            this function returns the params submited to an SMA Job

        .PARAMETER WebServiceEndPoint
            defines the https-address of the web service endpoint

        .PARAMETER Port
            defines the TCP port of the web service endpoint.

            this parameter is not mandatory, the default value is 9090

        .PARAMETER Credential
            defines credentials to access the SMA web service

        .PARAMETER JobId
            defines the job id for which the parameters should be returned

        .EXAMPLE
            get-SMAWSJobParams -WebServiceEndpoint $WebServiceEndpoint -Port $Port -JobID $JobId

    #>
    [OutputType([System.Object])]
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true )]
        [string]$WebServiceEndpoint
        ,
        [Parameter(Mandatory = $false )]
        [int]$Port = 9090
        ,
        [Parameter( Mandatory = $false )]
        [System.Management.Automation.PSCredential]$Credential
        ,
        [Parameter(Mandatory=$true)]
        [string]$JobID = '8d708a20-ccc5-4e8e-9d3e-7a69f7991651'
    )
    $function = $($MyInvocation.MyCommand.Name)
    Write-Verbose "Running $function"

    try {
        $BaseURI = "${WebServiceEndpoint}:$( $Port )/00000000-0000-0000-0000-000000000000/"
        if ( $BaseURI.Substring( 0,4 ) -ne 'http' ) {
            $BaseURI = "https://$( $BaseURI )"
        }

        $InvokeParams = @{}
        if ( [string]::IsNullOrEmpty( $Credential ) ) {
            $InvokeParams.Add( 'UseDefaultCredentials', $null )
        }
        else {
            $InvokeParams.Add( 'Credential', $Credential )
        }

        $JobEntry = Get-SMAWSEntries @SMAConnection -EntryType Jobs -Filter "JobID eq guid'$( $JobID )'"
        $ContextID = $JobEntry.properties.JobContextID.'#text'

        $URIJobParams = "${BaseURI}JobContexts(guid'${ContextID}')/JobParameters"
        $ResponseJobParams = Invoke-RestMethod -Uri $URIJobParams  -Method Get @InvokeParams -UseBasicParsing

        $JobParams = ( $ResponseJobParams.content.properties | Select-Object Name, Value )
        $res = New-Object -TypeName PSObject

        foreach ( $JobParam in $JobParams ) {
            $res | Add-Member -Name $JobParam.Name -MemberType NoteProperty -Value $JobParam.Value
        }

        return $res
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
