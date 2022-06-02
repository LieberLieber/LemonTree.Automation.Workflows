$branchName = "83-status-needs-disableenable-before-diff-or-checkin"
$automatedCheckinComment = "PCS Alias: LemonTree.PCS.Demo/83-status-needs-disableenable-before-diff-or-checkin"
$latestAutomatedCheckinID =""
echo "All comments in Branch:"
git log --walk-reflogs $branchName --pretty=%H%s
$output = git log --walk-reflogs $branchName --pretty=%H%s
echo ""
echo "Let's find the latest with text '$automatedCheckinComment'"

ForEach ($line in $($output -split "`r`n"))
{
    if ($line.Endswith($automatedCheckinComment))
    {
        $latestAutomatedCheckinID = $line.Replace($automatedCheckinComment,"") #remove the comment from the string
        break
    }
}
echo "Latest automated Checkin Comment: $latestAutomatedCheckinID"
$blobPointer="$latestAutomatedCheckinID"+":"+"Model.qeax"
echo $blobPointer
git fetch origin 
$pointer = git cat-file blob "$blobPointer"
$sha = ($pointer[1] -split(":"))[1]
if($sha -ne $null){
    $shaPart1 = $sha.Substring(0,2)
    $shaPart2 = $sha.Substring(2,2)
    echo "Model SHA: $sha"
    git cat-file --filters "33e3beb695c68b63b7ccff0351268b58daf9bb85:Model.qeax" | Out-Null
    copy ".git\lfs\objects\$shaPart1\$shaPart2\$sha" "Model_base.qeax"
    echo "::set-output name=result::downloaded"
}
else
{
    echo "::set-output name=result::notFound"
}