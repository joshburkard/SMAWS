function Get-SMAWSRunbookParams {
    <#
        .SYNOPSIS
            returns all possible parameters for a runbook

        .DESCRIPTION
            returns one or more runbooks based on the parameters

        .PARAMETER WebServiceEndPoint
            defines the https-address of the web service endpoint

        .PARAMETER Port
            defines the TCP port of the web service endpoint.

            this parameter is not mandatory, the default value is 9090

        .PARAMETER Credential
            defines credentials to access the SMA web service

        .PARAMETER RunbookName
            defines the filter by the name of the runbook

            this parameter is not mandatory. if not used, it will return all runbooks

        .EXAMPLE
            Get-SMAWSRunbookParams -WebServiceEndpoint $WebServiceEndpoint -Port $Port -RunbookName $RunbookName

    #>
    [OutputType([System.Object[]])]
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [string]$WebServiceEndpoint
        ,
        [Parameter(Mandatory=$false)]
        [int]$Port = 9090
        ,
        [Parameter( Mandatory = $false )]
        [System.Management.Automation.PSCredential]$Credential
        ,
        [Parameter(ParameterSetName='NameAndType',Mandatory=$false)]
        [string]$RunbookName
    )
    $function = $($MyInvocation.MyCommand.Name)
    Write-Verbose "Running $function"

    try {
        $BaseURI = "$( $WebServiceEndpoint ):$( $Port )/00000000-0000-0000-0000-000000000000/"
        if ( $BaseURI.Substring( 0,4 ) -ne 'http' ) {
            $BaseURI = "https://$( $BaseURI )"
        }
        $InvokeParams = @{
            WebServiceEndpoint = $WebServiceEndpoint
            Port = $Port
            RunbookName = $RunbookName
        }
        if ( -not ( [string]::IsNullOrEmpty( $Credential ) ) ) {
            $InvokeParams.Add( 'Credential', $Credential )
        }

        $Runbook = Get-SMAWSRunbook @InvokeParams

        $URI = $BaseURI + ( $Runbook.Links | Where-Object { $_.title -eq 'PublishedRunbookVersion' } ).href
        $InvokeParams = @{}
        $InvokeParams.Add( 'URI', $URI )
        $InvokeParams.Add( 'Method', 'Get' )
        if ( [string]::IsNullOrEmpty( $Credential ) ) {
            $InvokeParams.Add( 'UseDefaultCredentials', $null )
        }
        else {
            $InvokeParams.Add( 'Credential', $Credential )
        }
        $Response = Invoke-WebRequest @InvokeParams -UseBasicParsing

        $URI = $BaseURI + ( ( [xml]$Response.Content ).entry.link | Where-Object { $_.title -eq 'RunbookParameters' } ).href
        $InvokeParams = @{}
        $InvokeParams.Add( 'URI', $URI )
        $InvokeParams.Add( 'Method', 'Get' )
        if ( [string]::IsNullOrEmpty( $Credential ) ) {
            $InvokeParams.Add( 'UseDefaultCredentials', $null )
        }
        else {
            $InvokeParams.Add( 'Credential', $Credential )
        }

        $Response = Invoke-WebRequest @InvokeParams -UseBasicParsing
        $RunbookParameters = ( [xml]$Response.Content ).feed.entry.content.properties
        return $RunbookParameters
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
