function get-SMAWSJobs {
    <#
        .SYNOPSIS
            this function returns the Jobs

        .Description
            this function returns the Jobs

        .PARAMETER WebServiceEndPoint
            defines the https-address of the web service endpoint

        .PARAMETER Port
            defines the TCP port of the web service endpoint.

            this parameter is not mandatory, the default value is 9090

        .PARAMETER Credential
            defines credentials to access the SMA web service

        .PARAMETER JobID
            defines the job id for which the parameters should be returned

        .PARAMETER RunbookName
            defines the runbook name for which the parameters should be returned

        .PARAMETER RunbookID
            defines the runbook id for which the parameters should be returned

        .EXAMPLE
            get-SMAWSJobs -WebServiceEndpoint $WebServiceEndpoint -Port $Port

        .EXAMPLE
            get-SMAWSJobs -WebServiceEndpoint $WebServiceEndpoint -Port $Port -JobID $JobID

        .EXAMPLE
            get-SMAWSJobs -WebServiceEndpoint $WebServiceEndpoint -Port $Port -RunbookName $RunbookName

    #>
    [OutputType([System.Object[]])]
    [CmdletBinding(DefaultParametersetname="noParams")]
    Param (
        [Parameter(ParameterSetName='noParams' , Mandatory = $true )]
        [Parameter(ParameterSetName='RunbookName' , Mandatory = $true )]
        [Parameter(ParameterSetName='RunbookID' , Mandatory = $true )]
        [Parameter(ParameterSetName='JobID' , Mandatory = $true )]
        [string]$WebServiceEndpoint
        ,
        [Parameter(ParameterSetName='noParams' , Mandatory = $false )]
        [Parameter(ParameterSetName='RunbookName' , Mandatory = $false )]
        [Parameter(ParameterSetName='RunbookID' , Mandatory = $false )]
        [Parameter(ParameterSetName='JobID' , Mandatory = $false )]
        [int]$Port = 9090
        ,
        [Parameter(ParameterSetName='noParams' , Mandatory = $false )]
        [Parameter(ParameterSetName='RunbookName' , Mandatory = $false )]
        [Parameter(ParameterSetName='RunbookID' , Mandatory = $false )]
        [Parameter(ParameterSetName='JobID' , Mandatory = $false )]
        [System.Management.Automation.PSCredential]$Credential
        ,
        [Parameter(ParameterSetName='RunbookName', Mandatory = $false )]
        [string]$RunbookName
        ,
        [Parameter(ParameterSetName='RunbookID', Mandatory = $false )]
        [string]$RunbookID
        ,
        [Parameter(ParameterSetName='JobID', Mandatory = $false )]
        [string]$JobID
    )
    $function = $($MyInvocation.MyCommand.Name)
    Write-Verbose "Running $function"

    try {
        $BaseURI = "$( $WebServiceEndpoint ):$( $Port )"
        $InvokeParams = @{
            WebServiceEndpoint = $WebServiceEndpoint
            Port = $Port
        }
        if ( $Credential ) {
            $InvokeParams.Add( 'Credential', $Credential )
        }
        $EntryParams = $InvokeParams.Clone()
        $EntryParams.Add( 'EntryType', 'Jobs' )
        if ( $JobID ) {
            $Filter = "JobID eq guid'$( $JobID )'"
            $EntryParams.Add('Filter', $Filter )
            Write-Verbose -Message "getting all SMA Jobs ..."
            $JobEntries = Get-SMAWSEntries @EntryParams
            Write-Verbose -Message "found $( $JobEntries.Count ) SMA Jobs"
        }
        elseif ( ( $RunbookName ) -or ( $RunbookID ) ) {
            if ( $RunbookName ) {
                Write-Verbose -Message "getting Runbook ..."
                $Runbook = Get-SMAWSRunbook @InvokeParams -RunbookName $RunbookName
                $RunbookID = $Runbook.RunbookID
                Write-Verbose "  runbook found with id '$( $RunbookID )'"
            }
            else {
                Write-Verbose "runbook id '$( $RunbookID )' defined"
            }
            Write-Verbose "getting Runbook versions ..."
            $RunbooksVersions = Get-SMAWSEntries @InvokeParams -EntryType RunbookVersions -Filter "RunbookID eq guid'$( $RunbookID )'"
            $RunbooksVersionsIDs = $RunbooksVersions.properties.RunbookVersionID.'#text'
            Write-Verbose "  found $( @( $RunbooksVersions ).Count ) runbook versions"

            Write-Verbose "getting job contexts ..."
            $JobContextEntries = @()
            foreach ( $RunbooksVersionsID in $RunbooksVersionsIDs ) {
                Write-Verbose "  runbook version id $( $RunbooksVersionsID ) ..."
                $JobContextEntry = Get-SMAWSEntries -WebServiceEndpoint $WebServiceEndpoint  -EntryType JobContexts -Filter "RunbookVersionID eq guid'$( $RunbooksVersionsID )'"
                Write-Verbose "    found $( @( $JobContextEntry ).Count )"
                $JobContextEntries += $JobContextEntry
            }
            Write-Verbose "  total $( @( $JobContextEntries ).Count )"

            Write-Verbose "getting job entries for job context ..."
            $JobEntries = @()
            $JobContextEntry = @( $JobContextEntries )[0]
            foreach ( $JobContextEntry in $JobContextEntries ) {
                Write-Verbose "  job contect $( $JobContextEntry.content.properties.JobContextID.'#text' ) ..."
                $Filter = "JobContextID eq guid'$( $JobContextEntry.content.properties.JobContextID.'#text' )'"
                $JobEntries += Get-SMAWSEntries @EntryParams -Filter $Filter
            }
        }
        else {
            Write-Verbose -Message "getting all SMA Jobs ..."
            $JobEntries = Get-SMAWSEntries @EntryParams
        }
        Write-Verbose -Message "found $( $JobEntries.Count ) SMA Jobs"
        if ( $JobEntries ) {

            Write-Verbose -Message "creating Jobs array object ..."
            $Jobs = @()
            $JobEntry = $JobEntries[0]
            foreach ( $JobEntry in $JobEntries ) {
                # $JobEntry.properties
                $Jobs += [PSCustomObject]@{
                    JobID = $JobEntry.properties.JobID.'#text'
                    JobContextID = $JobEntry.properties.JobContextID.'#text'
                    JobStatus = $JobEntry.properties.JobStatus
                    StartTime = $JobEntry.properties.StartTime.'#text'
                    EndTime = $JobEntry.properties.EndTime.'#text'
                    CreationTime = $JobEntry.properties.CreationTime.'#text'
                    LastModifiedTime = $JobEntry.properties.LastModifiedTime.'#text'
                    ErrorCount = $JobEntry.properties.ErrorCount.'#text'
                    WarningCount = $JobEntry.properties.WarningCount.'#text'
                    JobException = $JobEntry.properties.JobException.'#text'
                }
            }
        }
        else {
            Write-Verbose -Message "Runbook not found"
            $Jobs = $null
        }
        return $Jobs
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
