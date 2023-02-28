# the purpose of this script is to replace LemonTree.Starter.exe for .mpms files.
# LemonTreeStarter will be enganged once three EA Models have been created useing LTA

# same parameters as LemonTree Starter
# --out=${mergedFile} --base=${baseFile} --mine=${rightFile} --theirs=${leftFile}
param
(
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


#create template models
Copy-Item $EABaseModel $BaseModel
&$LTAToolPath Import --Model $BaseModel --Components $base

Copy-Item $EABaseModel $MineModel
&$LTAToolPath Import --Model $MineModel --Components $mine

Copy-Item $EABaseModel $TheirsModel
&$LTAToolPath Import --Model $TheirsModel --Components $theirs

#use lemontree to merge the models.
$command = "--merge=auto --out=$ResultModel --base=$BaseModel --mine=$MineModel --theirs=$TheirsModel --singleSessionOnly"
$myprocss = Start-Process $LTSToolPath -PassThru -ArgumentList $command
$myprocss.WaitForExit()
Write-Output "LemonTree is finished"

#we could check for the result model here? for now we go forward

#guid extract from Filename? '{22b116db-59ea-a4fa-c52a-cc163a9f56bc}

#extract MPMS to the location of $out

