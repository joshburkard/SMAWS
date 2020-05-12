Import-Module .\SMAWS\SMAWS.psm1 -Force 
Import-Module Pester -MinimumVersion '4.6.0'


Describe "Get-SMAWSEntries" {
    $SMAConnection = @{
        WebServiceEndPoint = $WebServiceEndpoint
        Port = 9090
    }
    it "should connect to SMA server" {
        { Test-NetConnection -}
    }

    it "shouldn't throw" {
        { $Entries = Get-SMAWSEntries @SMAConnection -EntryType Runbooks } | should not throw
    }

    it "should contain multiple entries" {
        @( $Entries ).Count  | should -BeGreaterOrEqual 1
    }
}

