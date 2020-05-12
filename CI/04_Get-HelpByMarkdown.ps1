#region declarations
    $TestsPath = Split-Path $MyInvocation.MyCommand.Path
    $ScriptName = Split-Path $MyInvocation.MyCommand.Definition -Leaf
    $FunctionName = @( $ScriptName -split '\.' )[0]

    $RootFolder = (get-item $TestsPath).Parent
    $ModulePath = Join-Path -Path $RootFolder.FullName -ChildPath $RootFolder.BaseName

    Push-Location -Path $RootFolder.FullName

    Set-Location -Path $RootFolder.FullName

    $ModulePath = Get-ChildItem -Filter "*.psm1" -Path $ModulePath
    Import-Module $ModulePath.FullName -Force
    # Import-Module Pester -MinimumVersion 4.6 -Force

    $Functions = Get-Command -Module $ModulePath.BaseName -CommandType Function

    $HelpPath = Join-Path -Path $RootFolder.FullName -ChildPath 'docs\Functions'
    if ( -not ( Test-Path -Path $HelpPath ) ) {
        New-Item -Path $HelpPath -ItemType Directory
    }
#endregion declarations

#region functions
    function EncodePartOfHtml {
        param (
            [string]
            $Value
        )

        ($Value -replace '<', '&lt;') -replace '>', '&gt;'
    }

    function GetCode {
        param (
            $Example
        )
        $codeAndRemarks = ( ($Example | Out-String ) -replace ( $Example.title ), '').Trim() -split "`r`n"

        $code = New-Object "System.Collections.Generic.List[string]"
        $code = @()
        for ($i = 0; $i -lt $codeAndRemarks.Length; $i++) {
            <#
            if ( $codeAndRemarks[$i] -eq 'DESCRIPTION' -and $codeAndRemarks[$i + 1] -eq '-----------') {
                Write-Host "break"
                break
            }
            if (1 -le $i -and $i -le 2) {
                continue
            }
            #>
            $code += $codeAndRemarks[$i]
        }

        $code -join "`r`n"
    }

    function GetRemark {
        param (
            $Example
        )
        $codeAndRemarks = (($Example | Out-String) -replace ($Example.title), '').Trim() -split "`r`n"

        $isSkipped = $false
        $remark = New-Object "System.Collections.Generic.List[string]"
        for ($i = 0; $i -lt $codeAndRemarks.Length; $i++) {
            if (!$isSkipped -and $codeAndRemarks[$i - 2] -ne 'DESCRIPTION' -and $codeAndRemarks[$i - 1] -ne '-----------') {
                continue
            }
            $isSkipped = $true
            $remark.Add($codeAndRemarks[$i])
        }

        $remark -join "`r`n"
    }
#endregion functions

#region execution
    $Functions = @( $Functions | Sort-Object Name ) | Out-GridView -PassThru
    foreach ( $FunctionName in @( $Functions | Sort-Object Name ).Name ) {
        $Help = Get-Help $FunctionName -Full
        $Function = Get-Command -Name $FunctionName -Module $ModuleName
        $Ast = $Function.ScriptBlock.Ast
        $Examples = @( $Ast.GetHelpContent().EXAMPLES )

        #region create file content
            #region function name, SYNOPSIS
                $FileContent = @"
# $( $Help.Name )

## SYNOPSIS

$( $Help.Synopsis )


"@
            #endregion function name, SYNOPSIS

            #region SYNTAX
                $FileContent += @"
## SYNTAX

``````powershell
$( ( ( $Help.syntax | Out-String ) -replace "`r`n", "`r`n`r`n" ).Trim() )
``````


"@
            #endregion SYNTAX

            #region DESCRIPTION
                $FileContent += @"
## DESCRIPTION

$( ( $Help.description | Out-String ).Trim() )


"@
            #endregion DESCRIPTION

            #region PARAMETERS
                $FileContent += @"
## PARAMETERS


"@
                foreach ($parameter in $Help.parameters.parameter) {
                    $FileContent += @"
### -$($parameter.name) &lt;$($parameter.type.name)&gt;

$( ( $parameter.description | Out-String ).Trim() )

``````
$( ( ( ( $parameter | Out-String ).Trim() -split "`r`n")[-5..-1] | % { $_.Trim() } ) -join "`r`n" )

"@
                    if ( $Function.Parameters."$( $parameter.name )".Attributes[1].ValidValues ) {
                        $FileContent += @"

Valid Values:

"@
                        ( $Function.Parameters."$( $parameter.name )".Attributes[1].ValidValues ) | foreach {
                            $FileContent += @"
- $( $_ )

"@
                        }
                    }
                    $FileContent += @"
``````


"@
                }
            #endregion PARAMETERS

            #region INPUTS
                if ( $Help.inputTypes.inputType.type.name ) {
                    $FileContent += @"
## INPUTS

$( $Help.inputTypes.inputType.type.name )


"@
                }
            #endregion INPUTS

            #region OUTPUTS
                $FileContent += @"
## OUTPUTS

$($Help.returnValues.returnValue[0].type.name)


"@
            #endregion OUTPUTS

            #region NOTES
                if ( ( $Help.alertSet.alert | Out-String ).Trim() ) {
                    $FileContent += @"
## NOTES

``````
$( ( $Help.alertSet.alert | Out-String ).Trim() )
``````


"@
                }
            #endregion NOTES

            #region EXAMPLES
                $FileContent += @"
## EXAMPLES


"@
                for ($i = 0; $i -lt $Examples.Count; $i++) {
                    $FileContent += @"
### EXAMPLE $( $i + 1 )

``````powershell
$( ( @( $examples )[ $i ] ).ToString().Trim() )
``````


"@
                }
                <#
                foreach ($example in $Help.examples.example) {
                    $FileContent += @"
    ### $(($example.title -replace '-*', '').Trim())

``````powershell
$( @( $example.code ) -join "`r`n" )
``````

"@
                }
                #>
            #endregion EXAMPLES
        #endregion create file content

        #region save file
            $FileName = Join-Path -Path $HelpPath -ChildPath "$( $FunctionName ).md"
            if ( Test-Path -Path $FileName ) {
                Remove-Item -Path $FileName -Force -Confirm:$false
            }
            $FileContent | Out-File -FilePath $FileName -Force -Encoding utf8
        #endregion save file
    }
#endregion execution
