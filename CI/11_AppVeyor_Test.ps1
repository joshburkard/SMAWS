
$PSVersionTable
Write-Host "[TEST][START]" -ForegroundColor RED -BackgroundColor White
import-module pester
start-sleep -seconds 2

if ( $env:APPVEYOR_BUILD_FOLDER ) {
    Write-Output "started in AppVeyor"
    $BuildFolder = $env:APPVEYOR_BUILD_FOLDER
    $ProjectName = $env:APPVEYOR_PROJECT_NAME
    $Branch = $env:APPVEYOR_REPO_BRANCH
}
else {
    Write-Output "startet locally"
    $CurrentPath = $script:MyInvocation.MyCommand.Path
    $BuildFolder = ( [System.IO.FileInfo]$CurrentPath ).Directory.Parent.FullName
    $ProjectName = ( [System.IO.FileInfo]$CurrentPath ).Directory.Parent.Name
    $Branch = & git rev-parse --abbrev-ref HEAD 
}

Write-Output "OS Version: $( [environment]::OSVersion.Version )"
Write-Output "OS Version: $( [environment]::OSVersion.VersionString )"
write-output "BUILD_FOLDER: $($BuildFolder)"
write-output "PROJECT_NAME: $($ProjectName)"
write-output "BRANCH: $($Branch)"

$ModuleClonePath = Join-Path -Path $BuildFolder -ChildPath $ProjectName
Write-Output "MODULE CLONE PATH: $($ModuleClonePath)"

$moduleName = $ProjectName

Get-Module $moduleName -ListAvailable

#Pester Tests
write-verbose "invoking pester"
#$TestFiles = (Get-ChildItem -Path .\ -Recurse  | ?{$_.name.EndsWith(".ps1") -and $_.name -notmatch ".tests." -and $_.name -notmatch "build" -and $_.name -notmatch "Example"}).Fullname


# $res = Invoke-Pester -Path "$($env:APPVEYOR_BUILD_FOLDER)/Tests" -OutputFormat NUnitXml -OutputFile TestsResults.xml -PassThru #-CodeCoverage $TestFiles
$res = Invoke-Pester -Path "$($BuildFolder)/Tests/00-Module.tests.ps1" -OutputFormat NUnitXml -OutputFile TestsResults.xml -PassThru #-CodeCoverage $TestFiles

#Uploading Testresults to Appveyor
if ( $env:APPVEYOR_JOB_ID ) {
    (New-Object 'System.Net.WebClient').UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", (Resolve-Path ./TestsResults.xml))
}

if ($res.FailedCount -gt 0 -or $res.PassedCount -eq 0) { 
    $PSVersionTable
    $AllFailedTests = $res.TestResult | Where-Object {$_.Passed -eq $false}
    foreach ($failedTest in $AllFailedTests){

        "Describe: {0}" -f $failedTest.describe
        "Name: {0}" -f $failedTest.Name
        "Message: {0}" -f $failedTest.FailureMessage
    }
    throw "$($res.FailedCount) tests failed - $($res.PassedCount) successfully passed"
};


    
if ($res.FailedCount -eq 0 -and $res.successcount -ne 0) {
    If ($env:APPVEYOR_REPO_BRANCH -eq "master") {
        Write-host "[$($env:APPVEYOR_REPO_BRANCH)] All tested Passed, and on Branch 'master'"
        $OfficialModulePath = $env:PSModulePath.SPlit(";")[0]

        Copy-Item -Path $ModuleClonePath -Destination $OfficialModulePath -Recurse -Force

        Write-host "[$($env:APPVEYOR_REPO_BRANCH)][$($ModuleName)] Import module from: $($ModuleClonePath)\$($ModuleName).psd1" -ForegroundColor DarkGreen
        import-module "$($ModuleClonePath)\$($ModuleName).psd1" -Force
        try{
            $GalleryModule = Find-Module $ModuleName -ErrorAction stop
            $GalleryVersion = $GalleryModule.version 
        }catch{
            Write-host "[$($env:APPVEYOR_REPO_BRANCH)][$($ModuleName)] Module not found on the gallery (is this the First deployment perhaps?)"
        }
        $LocalVersion = (get-module $ModuleName).version.ToString()

        if($LocalVersion -eq ""){
            throw "Could not get version numbers"
        }

        if ($Localversion -le $GalleryVersion) {
            Write-host "[$($env:APPVEYOR_REPO_BRANCH)][$($ModuleName)] $($moduleName) version $($localversion)  is identical with the one on the gallery. No upload done."
            write-host "[$($env:APPVEYOR_REPO_BRANCH)][$($ModuleName)] Module not deployed to the psgallery" -foregroundcolor Yellow;
        }
        Else {
            $envIsLinux = $false
            if($IsLinux){

                $envIsLinux = $true
            }
            If($env:APPVEYOR_REPO_COMMIT_MESSAGE -match '^push psgallery.*$' -and $envIsLinux){

                try{
    
                    publish-module -Name $ModuleName -NuGetApiKey $Env:PSgalleryKey -ErrorAction stop;
                    write-host "[$($env:APPVEYOR_REPO_BRANCH)][$($ModuleName)][$($LocalVersion)] Module successfully deployed to the psgallery" -foregroundcolor green;
                }Catch{
                    write-host "[$($env:APPVEYOR_REPO_BRANCH)][$($ModuleName)][$($LocalVersion)] An error occured while publishing the module to the gallery" -foregroundcolor red;
                    write-host "[$($env:APPVEYOR_REPO_BRANCH)][$($ModuleName)][$($LocalVersion)] $_" -foregroundcolor red;
                }
            }else{
                write-host "[$($env:APPVEYOR_REPO_BRANCH)][$($LocalVersion)] All checks passed, but module not deployed to the gallery. " -foregroundcolor green;
            }

        }
    }Else{
        Write-host "[$($env:APPVEYOR_REPO_BRANCH)][$($ModuleName)] Awesome, nothing to do more. If you want to upload to the gallery, please merge from dev into master: use 'push gallery' in commit message to master to publish the module."
    }
}
else {
    Write-host "[$($env:APPVEYOR_REPO_BRANCH)][$($ModuleName)] Failed tests: $($res.failedcount) - Successfull tests: $($res.successcount)" -ForegroundColor Red
}
Write-Host "[TEST][END]" -ForegroundColor RED -BackgroundColor White