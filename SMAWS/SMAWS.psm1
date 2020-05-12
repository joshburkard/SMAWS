<#
    Generated at 03/14/2020 20:39:31 by Josh Burkard
#>
#region namespace SMAWS
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
function Get-SMAWSJobStatus {
    <#
        .SYNOPSIS
            returns the Status of a Job

        .DESCRIPTION
            returns the Status of a Job and the Output

        .PARAMETER WebServiceEndPoint
            defines the https-address of the web service endpoint

        .PARAMETER Port
            defines the TCP port of the web service endpoint.

            this parameter is not mandatory, the default value is 9090

        .PARAMETER Credential
            defines credentials to access the SMA web service

        .PARAMETER JobId
            define the id off the job to check

        .EXAMPLE
            $JobStatus = get-SMAWSJobStatus -WebServiceEndpoint $WebServiceEndpoint -Port $Port -JobID $JobId
            $JobStatus.Status
            $JobStatus.Output

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
        [string]$JobID # = 'fa2a86fd-aa6b-4a1a-87c9-853ae7924ef2'
    )
    $function = $($MyInvocation.MyCommand.Name)
    Write-Verbose "Running $function"

    try {
        $InvokeParams = @{}
        if ( [string]::IsNullOrEmpty( $Credential ) ) {
            $InvokeParams.Add( 'UseDefaultCredentials', $null )
        }
        else {
            $InvokeParams.Add( 'Credential', $Credential )
        }

        $URI = "$( $WebServiceEndpoint ):$( $Port )/00000000-0000-0000-0000-000000000000/Jobs(guid'$( $JobID )')"
        if ( $URI.Substring( 0,4 ) -ne 'http' ) {
            $URI = "https://$( $URI )"
        }

        $Response = Invoke-RestMethod -Uri $URI  -Method Get @InvokeParams -UseBasicParsing
        $JobStatus = $Response.entry.properties.JobStatus
        $URI =   "$( $WebServiceEndpoint ):$( $Port )/00000000-0000-0000-0000-000000000000/JobStreams/GetStreamItems?jobId='" + $JobID +"'&streamType='Any' "
        if ( $URI.Substring( 0,4 ) -ne 'http' ) {
            $URI = "https://$( $URI )"
        }

        $Results = Invoke-RestMethod -Uri $URI -Method Get @InvokeParams -UseBasicParsing

        $Output = @()
        foreach ( $Result in $Results ) {
            $Output += New-Object -TypeName PSObject -Property @{
                StreamTypeName = $Result.content.properties.StreamTypeName
                StreamTime     = ( Get-Date $Result.content.properties.StreamTime.InnerText )
                StreamText     = $Result.content.properties.StreamText.InnerText.Trim()
            }
        }

        return [PSCustomObject]@{
            JobID  = $JobID
            Status = $JobStatus
            Output = $Output
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
function Get-SMAWSRunbook {
    <#
        .SYNOPSIS
            returns one or more runbooks

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

        .PARAMETER RunbookId
            defines the filter by the id of the runbook

            this parameter is not mandatory. if not used, it will return all runbooks

        .PARAMETER RunbookType
            defines the filter by type: PowerShellWorkflow or PowerShellScript

            this parameter is not mandatory. if not used, it will return all runbooks

        .EXAMPLE
            Get-SMAWSRunbook -WebServiceEndpoint $WebServiceEndpoint -Port $Port [-RunbookType 'PowerShellWorkflow' / 'PowerShellScript']

        .EXAMPLE
            Get-SMAWSRunbook -WebServiceEndpoint $WebServiceEndpoint -Port $Port -RunbookName $RunbookName  [-RunbookType 'PowerShellWorkflow' / 'PowerShellScript']

        .EXAMPLE
            Get-SMAWSRunbook -WebServiceEndpoint $WebServiceEndpoint -Port $Port -RunbookID $RunbookID  [-RunbookType 'PowerShellWorkflow' / 'PowerShellScript']

    #>
    [OutputType([System.Object[]])]
    [CmdletBinding(DefaultParameterSetName='NoParams')]
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
        ,
        [Parameter(ParameterSetName='IdAndType',Mandatory=$false)]
        [string]$RunbookID
        ,
        [Parameter(ParameterSetName='NoParams')]
        [Parameter(ParameterSetName='NameAndType')]
        [Parameter(ParameterSetName='IdAndType')]
        [ValidateSet('PowerShellWorkflow', 'PowerShellScript')]
        [string]$RunbookType = $null
    )
    $function = $($MyInvocation.MyCommand.Name)
    Write-Verbose "Running $function"

    try {
        $EntryParams = @{
            WebServiceEndpoint = $WebServiceEndpoint
            Port               = $Port
            EntryType          = 'Runbooks'
        }
        if ( $Credential ) {
            $EntryParams.Add( 'Credential', $Credential )
        }
        $Filter = ''
        if ( $RunbookName ) {
            $Filter = "RunbookName eq '$( $RunbookName )'"
        }
        if ( $RunbookType ) {
            if ( $Filter -ne '' ) {
                $Filter += ' and '
            }
            switch ( $RunbookType ) {
                'PowerShellWorkflow' {
                    $Filter += "RunbookType eq Script"
                }
                'PowerShellScript' {
                    $Filter += "RunbookType eq 'PowerShellScript'"
                }
            }
        }
        if ( $Filter -ne '' ) {
            $EntryParams.Add( 'Filter', $Filter )
        }
        $RunbookEntries = Get-SMAWSEntries @EntryParams
        # $RunbookEntries = Get-SMAWSEntries -WebServiceEndpoint $WebServiceEndpoint  -EntryType Runbooks
        # $RunbooksVersions = Get-SMAWSEntries -WebServiceEndpoint $WebServiceEndpoint -EntryType RunbookVersions
        # $RunbookEntry = $RunbookEntries | Out-GridView -PassThru
        $RunbookEntry = @( $RunbookEntries )[0]
        $Runbooks = @()
        foreach ( $RunbookEntry in @( $RunbookEntries ) ){
            if ( [boolean]( $RunbookEntry.content.properties.RunbookWorker | Get-Member -MemberType Property -Name null ) ) {
                $RunbookWorker = $null
            }
            else {
                $RunbookWorker = $RunbookEntry.content.properties.RunbookWorker
            }
            if ( [boolean]( $RunbookEntry.content.properties.Tags | Get-Member -MemberType Property -Name null ) ) {
                $Tags = $null
            }
            else {
                $Tags = $RunbookEntry.content.properties.Tags
            }
            switch ( $RunbookEntry.content.properties.RunbookType ) {
                'Script' {
                    $Type = 'PowerShellWorkflow'
                }
                Default {
                    $Type = $RunbookEntry.content.properties.RunbookType
                }
            }

            $Runbooks += [PSCustomObject]@{
                RunbookID   = $RunbookEntry.content.properties.RunbookID.'#text'
                RunbookName = $RunbookEntry.content.properties.RunbookName
                CreationTime = $RunbookEntry.content.properties.CreationTime.'#text'
                LastModifiedTime = $RunbookEntry.content.properties.LastModifiedTime.'#text'
                LastModifiedBy = $RunbookEntry.content.properties.LastModifiedBy.'#text'
                Description = $RunbookEntry.content.properties.Description.'#text'
                PublishedRunbookVersionID = $RunbookEntry.content.properties.PublishedRunbookVersionID.'#text'
                DraftRunbookVersionID = $RunbookEntry.content.properties.DraftRunbookVersionID.'#text'
                # RunbookVersions = $RunbookVersions
                Tags = $Tags
                LogDebug = $RunbookEntry.content.properties.LogDebug.'#text'
                LogVerbose = $RunbookEntry.content.properties.LogVerbose.'#text'
                LogProgress = $RunbookEntry.content.properties.LogProgress.'#text'
                RunbookWorker = $RunbookWorker
                RunbookType = $Type
                Link = $RunbookEntry.id
                Links = $RunbookEntry.link
            }
        }

        if ( $RunbookName ) {
            $Runbooks = $Runbooks | Where-Object { $_.RunbookName -eq $RunbookName }
        }
        if ( $RunbookType ) {
            $Runbooks = $Runbooks | Where-Object { $_.RunbookType -eq $RunbookType }
        }
        return $Runbooks
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
function Invoke-SMAWSRunbook {
    <#
        .SYNOPSIS
            Invokes a SMA runbook through the Web Service

        .DESCRIPTION
            Invokes a SMA runbook through the Web Service

        .PARAMETER WebServiceEndPoint
            defines the https-address of the web service endpoint

            this parameter is mandatory

        .PARAMETER Port
            defines the TCP port of the web service endpoint.

            this parameter is not mandatory, the default value is 9090

        .PARAMETER Credential
            defines credentials to access the SMA web service

            this parameter is not mandatory

        .PARAMETER RunbookName
            defines the filter by the name of the runbook

            this parameter is mandatory

        .PARAMETER Params
            this parameter defines the parameters which should be submited to the runbook

            this parameter is not mandatory

        .PARAMETER wait
            if this switch parameter is set, the function will wait for the finish of the runbook

        .PARAMETER timeout
            this defines how long the function should wait for a result

            this parameter is not mandatory, the default value is 300 seconds

        .EXAMPLE
            # Example without params to submit

            [string]$WebServiceEndpoint = 'server.domain.fqdn'
            [int]$Port = 9090
            $Credential = New-Object System.Management.Automation.PSCredential ( 'user@domain.fqdn', ( ConvertTo-SecureString 'somePassword' -AsPlainText -Force ) )
            [string]$RunbookName = 'SA0-ALL-IMP-SCCM-AddNewDevice'

            $SMAConnection = @{
                WebServiceEndpoint = $WebServiceEndpoint
                Port = $Port
                $Credential = $Credential
            }

            Invoke-SMAWSRunbook @SMAConnection -RunbookName 'Test'

        .EXAMPLE
            # Example with params to submit

            $parameters = @{
                A = 'Test A'            # String value
                B = 25                  # Integer value
                C = @( 'Test B', 44 )   # Array value
                D = $true               # Boolean parameter ( Switch Parameter must be set like a boolean $true )
                E = '{"Name1":"Value1","Name2":"Value2"}' # JSON
            }

            Invoke-SMAWSRunbook @SMAConnection -RunbookName 'Test' -params $parameters

        .EXAMPLE
            # transfeer a file content to Runbook parameter 'FileContent'

            $FileContent = Get-Content -Path $FileName -Raw
            $Bytes = [System.Text.Encoding]::Unicode.GetBytes($FileContent)
            $EncodedText =[Convert]::ToBase64String($Bytes)

            $parameters = @{
                FileContent = $EncodedText
            }

            Invoke-SMAWSRunbook @SMAConnection -RunbookName 'Test' -params $parameters

    #>
    [OutputType([PSCustomObject])]
    [CmdLetBinding()]
    Param (
        [Parameter(Mandatory=$true)]
        [string]$WebServiceEndpoint
        ,
        [Parameter(Mandatory=$false)]
        [int]$Port = 9090
        ,
        [Parameter(Mandatory=$true)]
        [string]$RunbookName
        ,
        [Parameter( Mandatory = $false )]
        [System.Object]$Params
        ,
        [Parameter( Mandatory = $false )]
        [System.Management.Automation.PSCredential]$Credential
        ,
        [Parameter(Mandatory = $false )]
        [switch]$wait
        ,
        [Parameter(Mandatory = $false )]
        [int]$timeout = 300
    )
    $function = $($MyInvocation.MyCommand.Name)
    Write-Verbose "Running $function"

    try {
        $InvokeParams = @{}
        $InvokeParams.Add( 'WebServiceEndpoint', $WebServiceEndpoint )
        $InvokeParams.Add( 'Port', $Port )
        $InvokeParams.Add( 'RunbookName', $RunbookName )
        if ( -not ( [string]::IsNullOrEmpty( $Credential ) ) ) {
            $InvokeParams.Add( 'Credential', $Credential )
        }
        # $RunbookID is unknown and must be retrieved first
        $RunbookID = ( Get-SMAWSRunbook @InvokeParams ).RunbookID
        Write-Verbose "runbook found with id $( $RunbookID )"

        if ( [string]::IsNullOrEmpty( $RunbookID ) ) {
            return [PSCustomObject]@{
                JobID  = $null
                Status = 'Runbook not found'
                Output = $null
            }
        }
        else {
            $URI = "$( $WebServiceEndpoint ):$( $Port )/00000000-0000-0000-0000-000000000000/Runbooks(guid'$( $RunbookID )')/Start"
            if ( $URI.Substring( 0,4 ) -ne 'http' ) {
                $URI = "https://$( $URI )"
            }

            $Headers = @{"Accept" = "application/atom+xml,application/xml"}

            if ( [string]::IsNullOrEmpty( $Params ) ) {
                $ParamsA = @{}
            }
            else {
                $ParamsA = $Params.Clone()
            }
            if ( [boolean]$Credential ) {
                $ParamsA.Add( 'MicrosoftApplicationManagementStartedBy' , $Credential.UserName)
            }
            elseif ( ( $env:USERNAME ) -and ( $env:USERDOMAIN ) ) {
                $ParamsA.Add( 'MicrosoftApplicationManagementStartedBy' , "$( $env:USERDOMAIN )\\$( $env:USERNAME )" )
            }
            elseif ( $env:USERNAME ) {
                $ParamsA.Add( 'MicrosoftApplicationManagementStartedBy' , $env:USERNAME )
            }
            $BodyStart = @"
{"parameters":[

"@
            $Body = $BodyStart
            $Key = @( $ParamsA.Keys )[0]
            foreach ( $Key in @( $ParamsA.Keys ) ) {
                if ( $Body -ne $BodyStart ) {
                    $Body += ','
                }
                if ( $ParamsA."$Key".gettype().BaseType.Name -eq 'Array' ) {
                    [string]$Value = '"['
                    foreach ( $v in $ParamsA."$Key" ) {
                        if ( $Value -ne '"[' ) {
                            $Value += ','
                        }
                        if ( $v.GetType().Name -match 'int' ) {
                            $Value += $v
                        }
                        elseif ( $v.GetType().Name -match 'boolean' ) {
                            $Value += "'$( $v.ToString().ToLower() )'"
                        }
                        else {
                            $Value += "'$( $v )'"
                        }
                    }
                    $Value += ']"'
                }
                elseif ( $ParamsA."$Key".gettype().Name -eq 'Hashtable' ) {
                    $Hashtable = $ParamsA."$Key"
                    $Value = ( $Hashtable | ConvertTo-Json -Depth 50 ) # -replace '"', '""'
                }
                else {
                    if ( $ParamsA."$Key".GetType().Name -match 'boolean' ) {
                        $Value = """$( $ParamsA."$Key".ToString().ToLower() )"""
                    }
                    else {
                        $isJSON = $null
                        try {
                            $ParamsA."$Key" | ConvertFrom-Json -ErrorAction SilentlyContinue | Out-Null
                            $isJSON = $true
                        }
                        catch {
                            $isJSON = $false
                        }
                        if ( $isJSON ) {
                            $NewJSON = $ParamsA."$Key" | ConvertFrom-Json | ConvertTo-Json -Depth 100 -Compress
                            $NewJSON = '"\"' + ( $NewJSON -replace '"','\\\"' ) + '\""'
                            $Value = $NewJSON
                        }
                        else {
                            $Value = """$( $ParamsA."$Key" )"""
                        }
                    }
                }
                $Body += @"
{"__metadata":
{"type":"Orchestrator.ResourceModel.NameValuePair"},"Name":"$Key","Value": $( $Value ) }

"@
            }

            $Body += @"
]}
"@
            $InvokeParams = @{}
            $InvokeParams.Add( 'URI', $URI )
            $InvokeParams.Add( 'Headers', $Headers )
            $InvokeParams.Add( 'Body', $Body )
<#
#Example Body
$Body = @"
{"parameters":[
{"__metadata":
{"type":"Orchestrator.ResourceModel.NameValuePair"},"Name":"Collections","Value": "['P00003C5','AAA','BBB']" }
,{"__metadata":
{"type":"Orchestrator.ResourceModel.NameValuePair"},"Name":"MWStartTime","Value": "20:00" }
,{"__metadata":
{"type":"Orchestrator.ResourceModel.NameValuePair"},"Name":"Servers","Value": "['ABC123','ABC456','DEF123']" }
,{"__metadata":
{"type":"Orchestrator.ResourceModel.NameValuePair"},"Name":"MWDate","Value": "2033-12-31" }
,{"__metadata":
{"type":"Orchestrator.ResourceModel.NameValuePair"},"Name":"MWDuration","Value": "120" }
]}
"@
#>

            if ( [string]::IsNullOrEmpty( $Credential ) ) {
                $InvokeParams.Add( 'UseDefaultCredentials', $null )
            }
            else {
                $InvokeParams.Add( 'Credential', $Credential )
            }

            $Response = Invoke-RestMethod @InvokeParams -Method Post -ContentType "application/json;odata=verbose" -UseBasicParsing
            $JobID = $Response.Start.'#text'

            if ( -not $wait ) {
                Write-Verbose "no wait parameter was set, exiting with JobID as result"
                return [PSCustomObject]@{
                    JobID  = $JobID
                    Status = 'started'
                    Output = $null
                }
            }
            else {
                Write-Verbose "wait parameter was set, waiting for runbook results"
                $CheckParams = @{}
                $CheckParams.Add( 'WebServiceEndpoint', $WebServiceEndpoint )
                $CheckParams.Add( 'Port', $Port )
                $CheckParams.Add( 'JobId', $JobID )
                if ( -not ( [string]::IsNullOrEmpty( $Credential ) ) ) {
                    $CheckParams.Add( 'Credential', $Credential )
                }
                $JobStatus = ''
                $startDate = Get-Date
                do {
                    $JobStatus = Get-SMAWSJobStatus @CheckParams
                } while ( ( $JobStatus.Status -ne 'Completed' ) -and ( $JobStatus.Status -ne 'Failed' ) -and ( $startDate.AddSeconds( $timeout ) -gt (Get-Date) ) )
                return $JobStatus
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
#endregion
