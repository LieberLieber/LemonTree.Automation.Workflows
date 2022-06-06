Import-Module .\Modules\LemonTree.Desktop.psm1

$filename =".\DemoModel.eapx"

#convert the "windows path to a git path - works with realtive and absolute path. return -1 one on failure
$gitFilename = Get-GitMappedFilePaths($filename)
echo "filename parameter converted to git syntax $filename ==> $gitFilename"

#save the absolute path to the model before we change the working dir
$absoluteFilename = Get-Fullname $filename
Echo $absoluteFilename


$commitId = git rev-parse HEAD
Echo "Head CommitID $commitID"
$baseFileName = Get-DownloadedFilename $gitFilename $commitId
echo $baseFileName

#getrootids for the merge hint from the current model.
$modelRootIds = Get-ModelRootIds($absoluteFilename);

#build the parameter to call LemonTree with the merge hint
$mergeDecisionOverrides =""
$countRoots = 0
foreach($modelRootId in $modelRootIds) {
    if ($countRoots) #true when bigger than 0
    {
        $mergeDecisionOverrides += ","
    }
    $mergeDecisionOverrides += "$modelRootId"
    $mergeDecisionOverrides += ":B"
    $countRoots += 1
}
# Open LemonTree with Files. Commandline options https://help.lieberlieber.com/display/LT/VCS+Integration     
Echo "Starting LemonTree"
Echo $baseFileName
Echo $absoluteFilename
&'C:\Program Files\LieberLieber\LemonTree\LemonTree.exe' --merge=visual --base "$baseFileName" --theirs "$baseFileName" --mine "$absoluteFilename" --mergeDecisionOverrides="$mergeDecisionOverrides" -theirsAlias="HEAD"
exit 0