#the purpose of this script is to replace LemonTree.Starter.exe for .mpms files.
#LemonTreeStarter will be enganged once three EA Models have been created useing LTA

$LTAToolPath = "C:\Program Files\LieberLieber\LemonTree.Automation\LemonTree.Automation.exe"
$LTSToolPath = "C:\Program Files\LieberLieber\LemonTree\LemonTree.Starter.exe"

$dataFolder= "C:\LemonTreeTestData\MPMS Merge"
$mpmsfile = "SysML-22b116db-59ea-a4fa-c52a-cc163a9f56bc.mpms"
$EABaseModel = "C:\Program Files (x86)\Sparx Systems\EA\EABase.qea"
$BaseModel = "base.qeax"
$MineModel = "mine.qeax"
$TheirsModel = "theirs.qeax"
$ResultModel = "result.qeax"



Copy-Item $EABaseModel $BaseModel
Copy-Item $EABaseModel $MineModel
Copy-Item $EABaseModel $TheirsModel

$componentFile = "$dataFolder\base\$mpmsfile"
Write-Output $componentFile 
&$LTAToolPath Import --Model $BaseModel --Components $componentFile 

$componentFile = "$dataFolder\mine\$mpmsfile"
Write-Output $componentFile 
&$LTAToolPath Import --Model $MineModel --Components $componentFile 

$componentFile = "$dataFolder\theirs\$mpmsfile"
Write-Output $componentFile 
&$LTAToolPath Import --Model $TheirsModel --Components $componentFile 

&$LTSToolPath merge --out $ResultModel --base $BaseModel --mine $MineModel --theirs $TheirsModel

