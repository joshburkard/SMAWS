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
                    Start-Sleep -Seconds 1
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
