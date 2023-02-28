# the purpose of this script is to replace LemonTree.Starter.exe for .mpms files.
# LemonTreeStarter will be enganged once three EA Models have been created useing LTA

# same parameters as LemonTree Starter
# --out=${mergedFile} --base=${baseFile} --mine=${rightFile} --theirs=${leftFile}
param
(
    #afer testomg all the parameters should be Mandatory.
    [Parameter(Mandatory = $false)][string] $out = "C:\LemonTreeTestData\MPMS Merge\merge\SysML-22b116db-59ea-a4fa-c52a-cc163a9f56bc.mpms",
    [Parameter(Mandatory = $false)][string] $base ="C:\LemonTreeTestData\MPMS Merge\base\SysML-22b116db-59ea-a4fa-c52a-cc163a9f56bc.mpms",
    [Parameter(Mandatory = $false)][string] $mine ="C:\LemonTreeTestData\MPMS Merge\mine\SysML-22b116db-59ea-a4fa-c52a-cc163a9f56bc.mpms",
    [Parameter(Mandatory = $false)][string] $theirs ="C:\LemonTreeTestData\MPMS Merge\theirs\SysML-22b116db-59ea-a4fa-c52a-cc163a9f56bc.mpms"
)

#tool environment - adapt as needed
$LTAToolPath = "C:\Program Files\LieberLieber\LemonTree.Automation\LemonTree.Automation.exe"
$LTSToolPath = "C:\Program Files\LieberLieber\LemonTree\LemonTree.exe"
$EABaseModel = "C:\Program Files (x86)\Sparx Systems\EA\EABase.qea"

#define names of tempmodels
$BaseModel = "base.qeax"
$MineModel = "mine.qeax"
$TheirsModel = "theirs.qeax"
$ResultModel = "result.qeax"

function New-TemporaryModel 
{
    param
    (
        [Parameter(Mandatory = $true)][string] $TempModel,
        [Parameter(Mandatory = $true)][string] $componentFile
    )
    process
    {
        Write-Output "Create Model for $componentFile"
        Copy-Item $EABaseModel $TempModel
        &$LTAToolPath Import --Model $TempModel --Components $componentFile | out-null
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

Remove-TemporaryModels

#create template models
Write-Output "Creating temporary Models to be able to merge the .mpms files."
New-TemporaryModel $BaseModel  $base
New-TemporaryModel $MineModel $mine
New-TemporaryModel $TheirsModel $theirs

#use lemontree to merge the models.
Write-Output "Starting LemonTree"
$command = "--merge=auto --out=$ResultModel --base=$BaseModel --mine=$MineModel --theirs=$TheirsModel --singleSessionOnly"
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
$PackageDirectory = Split-Path -Path $out
&$LTAToolPath Publish --Model $ResultModel --All --PackageDirectory $PackageDirectory | out-null

Remove-TemporaryModels