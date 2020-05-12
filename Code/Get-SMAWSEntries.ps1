function Get-SMAWSEntries {
    <#
        .SYNOPSIS
            this function get entries from the SMA WebService

        .DESCRIPTION
            this function get entries from the SMA WebService

        .PARAMETER WebServiceEndPoint
            defines the https-address of the web service endpoint

        .PARAMETER Port
            defines the TCP port of the web service endpoint.

            this parameter is not mandatory, the default value is 9090

        .PARAMETER Credential
            defines credentials to access the SMA web service

        .PARAMETER EntryType
            defines the type of the entries to return

            this string parameter is mandatory

        .PARAMETER Filter
            defines the filter for this entries

            this string parameter is not mandatory

        .EXAMPLE
            Get-SMAWSEntries -WebServiceEndpoint $WebServiceEndpoint -Port $Port -EntryType Runbooks

        .EXAMPLE
            Get-SMAWSEntries -WebServiceEndpoint $WebServiceEndpoint -Port $Port -EntryType Runbooks -Filter "Name eq 'Top Test'"
    #>
    [OutputType('System.Object')]
    [CmdletBinding()]
    Param (
        [string]$WebServiceEndpoint
        ,
        [int]$Port = 9090
        ,
        [Parameter( Mandatory = $false )]
        [System.Management.Automation.PSCredential]$Credential
        ,
        [ValidateSet('Jobs', 'Runbooks', 'RunbookVersions', 'JobContexts', 'JobParameters', 'Schedules', 'Modules', 'ConnectionFields', 'ConnectionFieldValues', 'Connections', 'ConnectionTypes', 'Variables', 'Credentials', 'Certificates', 'Activities', 'ActivityParameterSets', 'ActivityParameters', 'ActivityOutputTypes', 'RunbookParameters', 'Statistics', 'AdminConfigurations', 'Deployment')]
        [string]$EntryType = 'Runbooks'
        ,
        [Parameter(Mandatory=$false)]
        [string]$Filter
    )
    $function = $($MyInvocation.MyCommand.Name)
    Write-Verbose "Running $function"

    try {
        $URI = "$( $WebServiceEndpoint ):$( $Port )/00000000-0000-0000-0000-000000000000/$( $EntryType )"
        if ( $URI.Substring( 0,4 ) -ne 'http' ) {
            $URI = "https://$( $URI )"
        }
        if ( $Filter ) {
            $URI = $URI + '?$filter=' + $Filter
        }
        $Entries = @()

        do {
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
            [XML]$Content = $Response.Content
            # $Content.service.workspace.collection
            foreach ( $Entry in $Content.feed.entry ) {
                $Entries += $Entry
            }
            $URI = $null
            $URI = ( $Content.LastChild.link | Where-Object { $_.rel -eq 'next' } ).href

        } while ( [boolean]$URI )
        $ret = $Entries
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
