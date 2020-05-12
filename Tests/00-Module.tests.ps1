#region declarations
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

    $TestsPath = $script:MyInvocation.MyCommand.Path
    $ScriptName = Split-Path $script:MyInvocation.MyCommand.Definition -Leaf
    # $TestsPath = Split-Path $MyInvocation.MyCommand.Path
    # $ScriptName = Split-Path $MyInvocation.MyCommand.Definition -Leaf
    $FunctionName = @( $ScriptName -split '\.' )[0]

    # $RootFolder = (get-item $TestsPath).Directory.Parent
    # $ModulePath = Join-Path -Path $RootFolder.FullName -ChildPath $RootFolder.BaseName
    $ModulePath = Join-Path -Path $BuildFolder -ChildPath $ProjectName
    Write-Output "ModulePath: $( $ModulePath )"
    Push-Location -Path $BuildFolder

    Set-Location -Path $BuildFolder

    $ModulePath = Get-ChildItem -Filter "*.psm1" -Path $ModulePath
    Write-Output "ModulePath Fullname: $( $ModulePath.FullName )"
    Import-Module $ModulePath.FullName -Force
    # Import-Module Pester -MinimumVersion 4.6 -Force

    $Functions = Get-Command -Module $ModulePath.BaseName -CommandType Function
    $CommonPrefix = 'SMAWS'
#endregion declarations

#region Pester tests
    # $Functions = $Functions | Out-GridView -PassThru
    # Clear-Host
    foreach ( $FunctionName in @( $Functions.Name | Sort-Object ) ) {
        Describe "default tests for $( $FunctionName )" {
            $command = Get-Command -Name $script:FunctionName -All
            $help = Get-Help -Name $script:FunctionName
            $Ast = $command.ScriptBlock.Ast

            <#
            @( $Ast.FindAll( { $true } , $true ) ) | Where-Object { $_.Extent.Text -eq '[cmdletbinding()]' } | select *
            @( $Ast.FindAll( { $true } , $true ) ) | Group-Object TypeName
            @( $Ast.FindAll( { $true } , $true ) ) | Out-Gridview
            #>
            $Verb = @( $script:FunctionName -split '-' )[0]
            It "verb '$( $Verb )' should be approved" {
                ( $Verb -in @( Get-Verb ).Verb ) | Should -Be $true
            }

            try {
                $FunctionPrefix = @( $script:FunctionName -split '-' )[1].Substring( 0, $CommonPrefix.Length )
            }
            catch {
                $FunctionPrefix = @( $script:FunctionName -split '-' )[1]
            }
            it "function Noon should have the Prefix '$( $CommonPrefix )'" {
                $FunctionPrefix | Should -Be $CommonPrefix
            }

            It "Synopsis should exist" {
                ( $command.ScriptBlock -match '.SYNOPSIS' ) | Should -Be $true
            }
            It "Description should exist" {
                ( [string]::IsNullOrEmpty( $help.description.Text  ) ) | Should -Be $false
            }
            It "Example should exist" {
                [boolean]( $help.examples ) | Should -Be $true
            }
            It "[CmdletBinding()] should exist" {
                [boolean]( @( $Ast.FindAll( { $true } , $true ) ) | Where-Object { $_.TypeName.Name -eq 'cmdletbinding' } ) | Should -Be $true
            }
            It "[OutputType] should exist" {
                [boolean]( @( $Ast.FindAll( { $true } , $true ) ) | Where-Object { $_.TypeName.Name -eq 'OutputType' } ) | Should -Be $true
            }
            Context "parameters" {
                $DefaultParams = @( 'Verbose', 'Debug', 'ErrorAction', 'WarningAction', 'InformationAction', 'ErrorVariable', 'WarningVariable', 'InformationVariable', 'OutVariable', 'OutBuffer', 'PipelineVariable')
                foreach ( $p in @( $command.Parameters.Keys | Where-Object { $_ -notin $DefaultParams } | Sort-Object ) ) {
                    It "help-text for paramater '$( $p )' should exist" {
                        ( $p -in $help.parameters.parameter.name ) | Should -Be $true
                    }

                    $Declaration = ( ( @( $Ast.FindAll( { $true } , $true ) ) | Where-Object { $_.Name.Extent.Text -eq "$('$')$p" } ).Extent.Text -replace 'INT32', 'INT' )
                    $VariableType = ( ( "\[$( $command.Parameters."$p".ParameterType.Name )\]" -replace 'INT32', 'INT' ) -replace 'SwitchParameter', 'Switch' )
                    $VariableTypeFull = "\[$( $command.Parameters."$p".ParameterType.FullName )\]"

                    $VariableType = $command.Parameters."$p".ParameterType.Name
                    $VariableType = $VariableType -replace 'INT32', 'INT'
                    $VariableType = $VariableType -replace 'SwitchParameter', 'Switch'
                    It "type '[$( $command.Parameters."$p".ParameterType.Name )]' should be declared for parameter '$( $p )'" {
                        ( ( $Declaration -match $VariableType ) -or ( $Declaration -match $VariableTypeFull ) ) | Should -Be $true
                    }
                }
            }
            Context "variables" {
                $code = $command.ScriptBlock
                $ScriptVariables = $code.Ast.FindAll( { $true } , $true ) |
                    Where-Object { $_.GetType().Name -eq 'VariableExpressionAst' } |
                    Select-Object -Property VariablePath -ExpandProperty Extent

                foreach ( $sv in @( $ScriptVariables | Select-Object -ExpandProperty Text -Unique | Sort-Object ) ) {
                    It "variable '$( $sv )' should be in same (upper/lower) case everywhere" {
                        [boolean]( $ScriptVariables | Where-Object { ( ( $_.Text -eq $sv ) -and ( $_.Text -cne $sv ) ) } ) | Should -Be $false
                    }
                }
            }
        }
    }
#endregion Pester tests