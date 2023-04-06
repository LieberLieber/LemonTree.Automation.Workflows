# the purpose of this script is to replace LemonTree.Starter.exe for .mpms files.
# LemonTreeStarter will be enganged once three EA Models have been created useing LTA

# same parameters as LemonTree Starter
# --out=${mergedFile} --base=${baseFile} --mine=${rightFile} --theirs=${leftFile}
param
(
    #Sample Commandline:
    #.\mpmsMerge.ps1 -base "C:\LemonTreeTestData\MPMS Merge\base\SysML-22b116db-59ea-a4fa-c52a-cc163a9f56bc.mpms" -theirs "C:\LemonTreeTestData\MPMS Merge\theirs\SysML-22b116db-59ea-a4fa-c52a-cc163a9f56bc.mpms" -mine "C:\LemonTreeTestData\MPMS Merge\mine\SysML-22b116db-59ea-a4fa-c52a-cc163a9f56bc.mpms" -out "C:\LemonTreeTestData\MPMS Merge\merge\SysML-22b116db-59ea-a4fa-c52a-cc163a9f56bc.mpms"
    [Parameter(Mandatory = $true)][string] $out,
    [Parameter(Mandatory = $true)][string] $base,
    [Parameter(Mandatory = $true)][string] $mine,
    [Parameter(Mandatory = $true)][string] $theirs
)

function Exit-IfFileNotExists
{
    param
    (
        [Parameter(Mandatory = $true)][string]$filename
    )
    process
    {
        if (-not(Test-Path -Path $filename -PathType Leaf)) 
        {
            Write-Output "File not found $filename"
            Exit -1
        }
    }
}

function Get-Fullname 
{
    param
    (
        [Parameter(Mandatory = $true)][string]$filename
    )
    process
    {
        if (Test-Path $filename) 
        {
            (Get-Item $fileName).FullName
        } 
    }
}

function Get-ModelRootIds  
{
    param
    (
        [Parameter(Mandatory = $true)][string] $model
    )
    process
    {
        #SqLite from powershell gave me unreliable results so I put the SqLite logic into a small Pipeline Tool.
        $results = &$ModelRootToolPath --Model $model --Ignore "{5BEEF931-53C8-4FE3-A607-71FACADE381B}"
        # if ($ExitCode -ne 0)
        # {
        #     Exit $ExitCode
        # }

        #Write-Output "Results $results"
        return @($results);
        #Comment this in to run in x86 space with Jet Driver
    }
}

function New-TemporaryModel 
{
    param
    (
        [Parameter(Mandatory = $true)][string] $TempModel,
        [Parameter(Mandatory = $true)][string] $componentFile
    )
    process
    {
        Exit-IfFileNotExists $componentFile

        Write-Output "Create Model for $componentFile"
        
        Copy-Item $EABaseModel $TempModel
        
        &$LTAToolPath Import --Model $TempModel --Components $componentFile 
        #| out-null
        
        Write-Output "Created $TempModel"
        
    }
}

function Remove-TemporaryModel
{   
    param
    (
        [Parameter(Mandatory = $true)][string] $ModelName
    )
    process
    {
        if (Test-Path $ModelName) {
            Remove-Item -Force $ModelName
          }
    }
}

function Remove-TemporaryModels
{
    process
    {
        Write-Output "Cleaning up!"
        Remove-TemporaryModel $BaseModel
        Remove-TemporaryModel $MineModel
        Remove-TemporaryModel $TheirsModel
        Remove-TemporaryModel $ResultModel
    }
}

$timestamp = Get-Date 
Write-Output "mpmsMerge1.ps1 started at $timestamp"

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

Write-Output "base: {$base}"
Write-Output "theirs: {$theirs}"
Write-Output "mine: {$mine}"
Write-Output "out: {$out}"

Exit-IfFileNotExists $base

#set workingdirectory to the directory of $base
$workingDirectory = Split-Path -Path $base
Write-Output "Working Directory: $workingDirectory"
Write-Output "Script Directory: $scriptPath"
Set-Location -Path $workingDirectory

#tool environment - adapt as needed
$LTAToolPath = "C:\Program Files\LieberLieber\LemonTree.Automation\LemonTree.Automation.exe"
$LTSToolPath = "C:\Program Files\LieberLieber\LemonTree\LemonTree.exe"
$ModelRootToolPath = $scriptPath + "\LemonTree.Pipeline.Tools.GetModelRoots.exe"
$EABaseModel = "C:\Program Files (x86)\Sparx Systems\EA\EABase.qea"

Exit-IfFileNotExists $LTAToolPath
Exit-IfFileNotExists $LTSToolPath
Exit-IfFileNotExists $ModelRootToolPath
Exit-IfFileNotExists $EABaseModel

#define names of tempmodels
$BaseModel = "base.qeax"
$MineModel = "mine.qeax"
$TheirsModel = "theirs.qeax"
$ResultModel = "result.qeax"

Remove-TemporaryModels

#create template models
Write-Output "Creating temporary Models to be able to merge the .mpms files."
New-TemporaryModel $BaseModel  $base
New-TemporaryModel $MineModel $mine
New-TemporaryModel $TheirsModel $theirs

#create merge override for MPMS Package - default to theirs.

#get the main modelroot
$rootId = Get-ModelRootIds $BaseModel
Write-Output "Found RootId  $rootId[1]" #--package=$rootId 
#use lemontree to merge the models.
Write-Output "Starting LemonTree"
$command = "--merge=visual --out=$ResultModel --base=$BaseModel --mine=$MineModel --theirs=$TheirsModel --singleSessionOnly --package=$rootId"# --mergeDecisionOverrides=`"{5BEEF931-53C8-4FE3-A607-71FACADE381B}:A`""
Write-Output $command
$myprocss = Start-Process $LTSToolPath -PassThru -ArgumentList $command
$myprocss.WaitForExit()
$ExitCode = $myprocss.ExitCode
Write-Output "LemonTree is finished with ExitCode $ExitCode" 
If ($ExitCode -ne 0)
{
    Write-Output "LemonTree merge was aborted or otherwhise unsuccesfull!"
    Remove-TemporaryModels
    Exit $ExitCode
}

#we could check for the result model here? for now we go forward

#extract MPMS to the location of $out
#guid extract from Filename? Should probably use the envelope '{22b116db-59ea-a4fa-c52a-cc163a9f56bc}
#with this trick we don't need to figure out the guid ;)
Write-Output "Extracting component from merged model!"
$out = ".\$out" #sourcetree workaround
$PackageDirectory = Split-Path -Path $out
Write-Output  "Package Dir: $PackageDirectory extracted from $out with $ResultModel"
&$LTAToolPath Publish --Model $ResultModel --All --PackageDirectory $PackageDirectory 
#This shoule be the $outfile not the $PackageDirectory
Remove-TemporaryModels
