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

