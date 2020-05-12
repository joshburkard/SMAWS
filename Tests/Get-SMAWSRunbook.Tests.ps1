Import-Module .\SMAWS\SMAWS.psm1 -Force 
Import-Module Pester -MinimumVersion '4.6.0'

$SMAConnection = @{
    WebServiceEndPoint = 'localhost'
    Port = 9090
}

Describe "Get-SMAWSRunbook" {
    #region Mock Get-SMAWSEntries if there is no connectivity
        if ( ( Test-NetConnection -ComputerName $SMAConnection.WebServiceEndPoint -Port $SMAConnection.Port -WarningAction SilentlyContinue ).TcpTestSucceeded -eq $false ) {

            Mock "Get-SMAWSEntries" -ModuleName SMAWS {
                $XMLContent = @"
<entry xmlns="http://www.w3.org/2005/Atom">
	<id>https:/$( $SMAConnection.WebServiceEndPoint ):$( $SMAConnection.Port )/00000000-0000-0000-0000-000000000000/Runbooks(guid'6f5cdbd1-388f-400a-9e70-3b6277b62236')</id>
	<category term="Orchestrator.ResourceModel.Runbook" scheme="http://schemas.microsoft.com/ado/2007/08/dataservices/scheme" />
	<link rel="edit" title="Runbook" href="Runbooks(guid'6f5cdbd1-388f-400a-9e70-3b6277b62236')" />
	<link rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/Statistics" type="application/atom+xml;type=entry" title="Statistics" href="Runbooks(guid'6f5cdbd1-388f-400a-9e70-3b6277b62236')/Statistics" />
	<link rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/DraftRunbookVersion" type="application/atom+xml;type=entry" title="DraftRunbookVersion" href="Runbooks(guid'6f5cdbd1-388f-400a-9e70-3b6277b62236')/DraftRunbookVersion" />
	<link rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/PublishedRunbookVersion" type="application/atom+xml;type=entry" title="PublishedRunbookVersion" href="Runbooks(guid'6f5cdbd1-388f-400a-9e70-3b6277b62236')/PublishedRunbookVersion" />
	<link rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/Schedules" type="application/atom+xml;type=feed" title="Schedules" href="Runbooks(guid'6f5cdbd1-388f-400a-9e70-3b6277b62236')/Schedules" />
	<title />
	<updated>2019-07-03T11:22:09Z</updated>
	<author>
		<name />
	</author>
	<m:action metadata="https:/$( $SMAConnection.WebServiceEndPoint ):$( $SMAConnection.Port )/00000000-0000-0000-0000-000000000000/$('$')metadata#OrchestratorApi.Start" title="Start" target="https:/$( $SMAConnection.WebServiceEndPoint ):$( $SMAConnection.Port )/00000000-0000-0000-0000-000000000000/Runbooks(guid'6f5cdbd1-388f-400a-9e70-3b6277b62236')/Start" xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" />
	<m:action metadata="https:/$( $SMAConnection.WebServiceEndPoint ):$( $SMAConnection.Port )/00000000-0000-0000-0000-000000000000/$('$')metadata#OrchestratorApi.StartOnSchedule" title="StartOnSchedule" target="https:/$( $SMAConnection.WebServiceEndPoint ):$( $SMAConnection.Port )/00000000-0000-0000-0000-000000000000/Runbooks(guid'6f5cdbd1-388f-400a-9e70-3b6277b62236')/StartOnSchedule" xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" />
	<m:action metadata="https:/$( $SMAConnection.WebServiceEndPoint ):$( $SMAConnection.Port )/00000000-0000-0000-0000-000000000000/$('$')metadata#OrchestratorApi.GetStatistics" title="GetStatistics" target="https:/$( $SMAConnection.WebServiceEndPoint ):$( $SMAConnection.Port )/00000000-0000-0000-0000-000000000000/Runbooks(guid'6f5cdbd1-388f-400a-9e70-3b6277b62236')/GetStatistics" xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" />
	<m:action metadata="https:/$( $SMAConnection.WebServiceEndPoint ):$( $SMAConnection.Port )/00000000-0000-0000-0000-000000000000/$('$')metadata#OrchestratorApi.Publish" title="Publish" target="https:/$( $SMAConnection.WebServiceEndPoint ):$( $SMAConnection.Port )/00000000-0000-0000-0000-000000000000/Runbooks(guid'6f5cdbd1-388f-400a-9e70-3b6277b62236')/Publish" xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" />
	<m:action metadata="https:/$( $SMAConnection.WebServiceEndPoint ):$( $SMAConnection.Port )/00000000-0000-0000-0000-000000000000/$('$')metadata#OrchestratorApi.Edit" title="Edit" target="https:/$( $SMAConnection.WebServiceEndPoint ):$( $SMAConnection.Port )/00000000-0000-0000-0000-000000000000/Runbooks(guid'6f5cdbd1-388f-400a-9e70-3b6277b62236')/Edit" xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" />
	<m:action metadata="https:/$( $SMAConnection.WebServiceEndPoint ):$( $SMAConnection.Port )/00000000-0000-0000-0000-000000000000/$('$')metadata#OrchestratorApi.Test" title="Test" target="https:/$( $SMAConnection.WebServiceEndPoint ):$( $SMAConnection.Port )/00000000-0000-0000-0000-000000000000/Runbooks(guid'6f5cdbd1-388f-400a-9e70-3b6277b62236')/Test" xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" />
	<content type="application/xml">
		<m:properties xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata">
			<d:TenantID m:type="Edm.Guid" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices">00000000-0000-0000-0000-000000000000</d:TenantID>
			<d:RunbookID m:type="Edm.Guid" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices">6f5cdbd1-388f-400a-9e70-3b6277b62236</d:RunbookID>
            <RunbookName>Test-Runbook</RunbookName>
			<d:CreationTime m:type="Edm.DateTime" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices">2015-01-01T02:00:00.000</d:CreationTime>
			<d:LastModifiedTime m:type="Edm.DateTime" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices">2015-01-01T01:00:00.000</d:LastModifiedTime>
			<d:LastModifiedBy m:null="true" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices" />
			<d:Description m:null="true" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices" />
			<d:IsApiOnly m:type="Edm.Boolean" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices">false</d:IsApiOnly>
			<d:IsGlobal m:type="Edm.Boolean" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices">false</d:IsGlobal>
			<d:PublishedRunbookVersionID m:type="Edm.Guid" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices">0d290d29b817-1ca5-43d3-93e0-cc282dbecac5</d:PublishedRunbookVersionID>
			<d:DraftRunbookVersionID m:type="Edm.Guid" m:null="true" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices" />
			<Tags>SystemRunbook</Tags>
			<d:LogDebug m:type="Edm.Boolean" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices">false</d:LogDebug>
			<d:LogVerbose m:type="Edm.Boolean" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices">false</d:LogVerbose>
			<d:LogProgress m:type="Edm.Boolean" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices">false</d:LogProgress>
			<d:RunbookWorker m:null="true" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices" />
			<RunbookType>Script</RunbookType>
		</m:properties>
	</content>
</entry>
"@
                $XMLContent | Out-File -FilePath 'C:\temp\test.xml'
                return @( ( [xml]($XMLContent) ).entry )
            } -ParameterFilter { $EntryType -eq 'Runbooks' }

            Mock "Get-SMAWSEntries" -Verifiable -ModuleName SMAWS {
                $XMLContent = @"
        <entry xmlns="http://www.w3.org/2005/Atom">
        <id>https:/$( $SMAConnection.WebServiceEndPoint ):$( $SMAConnection.Port )/00000000-0000-0000-0000-000000000000/RunbookVersions(guid'0d29b817-1ca5-43d3-93e0-cc282dbecac5')</id>
        <category term="Orchestrator.ResourceModel.RunbookVersion" scheme="http://schemas.microsoft.com/ado/2007/08/dataservices/scheme" />
        <link rel="edit" title="RunbookVersion" href="RunbookVersions(guid'0d29b817-1ca5-43d3-93e0-cc282dbecac5')" />
        <link rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/JobContexts" type="application/atom+xml;type=feed" title="JobContexts" href="RunbookVersions(guid'0d29b817-1ca5-43d3-93e0-cc282dbecac5')/JobContexts" />
        <link rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/Runbook" type="application/atom+xml;type=entry" title="Runbook" href="RunbookVersions(guid'0d29b817-1ca5-43d3-93e0-cc282dbecac5')/Runbook" />
        <link rel="http://schemas.microsoft.com/ado/2007/08/dataservices/related/RunbookParameters" type="application/atom+xml;type=feed" title="RunbookParameters" href="RunbookVersions(guid'0d29b817-1ca5-43d3-93e0-cc282dbecac5')/RunbookParameters" />
        <title />
        <updated>2019-07-04T05:51:35Z</updated>
        <author>
            <name />
        </author>
        <link rel="edit-media" title="RunbookVersion" href="RunbookVersions(guid'0d29b817-1ca5-43d3-93e0-cc282dbecac5')/$('$')value" m:etag="&quot;636977494209700000&quot;" xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" />
        <content type="application/octet-stream" src="RunbookVersions(guid'0d29b817-1ca5-43d3-93e0-cc282dbecac5')/$('$')value" />
        <m:properties xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata">
            <d:TenantID m:type="Edm.Guid" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices">00000000-0000-0000-0000-000000000000</d:TenantID>
            <d:RunbookVersionID m:type="Edm.Guid" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices">0d29b817-1ca5-43d3-93e0-cc282dbecac5</d:RunbookVersionID>
            <d:RunbookID m:type="Edm.Guid" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices">6f5cdbd1-388f-400a-9e70-3b6277b62236</d:RunbookID>
            <d:VersionNumber m:type="Edm.Int32" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices">18</d:VersionNumber>
            <d:IsDraft m:type="Edm.Boolean" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices">false</d:IsDraft>
            <d:CreationTime m:type="Edm.DateTime" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices">2019-07-03T11:17:00.97</d:CreationTime>
            <d:LastModifiedTime m:type="Edm.DateTime" xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices">2019-07-03T11:17:00.97</d:LastModifiedTime>
        </m:properties>
    </entry>
"@
                return @( ( [xml]($XMLContent) ).entry )
            } -ParameterFilter { $EntryType -eq 'RunbookVersions' }
        }
    #endregion Mock Get-SMAWSEntries if there is no connectivity

    it "shouldn't throw" {
        { Get-SMAWSRunbook @SMAConnection -RunbookName $RBName } | should not throw
    }

    $Runbooks = Get-SMAWSRunbook @SMAConnection 

    it "minimum 1 Runbook should be found" {
        @( $Runbooks ).Count | Should -BeLessOrEqual 1
    }

    $Runbook = @( $Runbooks )[0]
    $Members = $Runbook | Get-Member -MemberType NoteProperty
    # $Runbook.runbookName

    $NeededMember = @()
    $NeededMember += [PSCustomObject]@{ Name = 'CreationTime';              Type = 'String' }
    $NeededMember += [PSCustomObject]@{ Name = 'Description';               Type = 'String' }
    $NeededMember += [PSCustomObject]@{ Name = 'DraftRunbookVersionID';     Type = 'String' }
    $NeededMember += [PSCustomObject]@{ Name = 'LastModifiedBy';            Type = 'String' }
    $NeededMember += [PSCustomObject]@{ Name = 'LastModifiedTime';          Type = 'String' }
    $NeededMember += [PSCustomObject]@{ Name = 'Link';                      Type = 'String' }
    $NeededMember += [PSCustomObject]@{ Name = 'Links';                     Type = 'String' }
    $NeededMember += [PSCustomObject]@{ Name = 'LogDebug';                  Type = 'String' }
    $NeededMember += [PSCustomObject]@{ Name = 'LogProgress';               Type = 'String' }
    $NeededMember += [PSCustomObject]@{ Name = 'LogVerbose';                Type = 'String' }
    $NeededMember += [PSCustomObject]@{ Name = 'PublishedRunbookVersionID'; Type = 'String' }
    $NeededMember += [PSCustomObject]@{ Name = 'RunbookID';                 Type = 'String' }
    $NeededMember += [PSCustomObject]@{ Name = 'RunbookName';               Type = 'String' }
    $NeededMember += [PSCustomObject]@{ Name = 'RunbookType';               Type = 'String' }
    $NeededMember += [PSCustomObject]@{ Name = 'RunbookVersions';           Type = 'String' }
    $NeededMember += [PSCustomObject]@{ Name = 'RunbookWorker';             Type = 'String' }
    $NeededMember += [PSCustomObject]@{ Name = 'Tags';                      Type = 'String' }
    
    foreach ( $NeededMember in $NeededMembers ) {
        Context $NeededMember.Name {
            it "should exist" {
                [boolean]( $Members | Where-Object { $_.Name -eq $NeededMember.Name } ) | should be $true
            }
        }
    }
}
