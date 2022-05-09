$automatedCheckinComment = "PCS Alias: LemonTree.PCS.Demo/83-status-needs-disableenable-before-diff-or-checkin"
$latestAutomatedCheckinID =""
echo "All comments in Branch:"
git log --walk-reflogs 83-status-needs-disableenable-before-diff-or-checkin --pretty=%H%s
$output = git log --walk-reflogs 83-status-needs-disableenable-before-diff-or-checkin --pretty=%H%s
echo ""
echo "Let's find the latest with text '$automatedCheckinComment'"

ForEach ($line in $($output -split "`r`n"))
{
    if ($line.Endswith($automatedCheckinComment))
    {
        $latestAutomatedCheckinID = $line.Replace($automatedCheckinComment,"") #remove the comment from the string
        Echo "$latestAutomatedCheckinID"
        return
    }
}
echo "Latest automated Checkin Comment: $latestAutomatedCheckinID"

