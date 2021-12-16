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
            $StreamTypeName = try { $Result.content.properties.StreamTypeName } catch { $null }
            $StreamTime = try { ( Get-Date $Result.content.properties.StreamTime.InnerText ) } catch { $null }
            $StreamText = try { $Result.content.properties.StreamText.InnerText.Trim() } catch { $null }
            $Output += New-Object -TypeName PSObject -Property @{
                StreamTypeName = $StreamTypeName
                StreamTime     = $StreamTime
                StreamText     = $StreamText
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
