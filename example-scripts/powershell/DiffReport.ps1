$output = &"C:\Program Files\LieberLieber\LemonTree.Automation\LemonTree.Automation.exe" diff --theirs C:\PCS\Models\LemonTree.PCS.Demo\3-demo-nizam\model.qeax --mine C:\PCS\Models\LemonTree.PCS.Demo\8-demo3\model.qeax

$diffResult = ""
ForEach ($line in $($output -split "`r`n"))
{
    if ($line.EndsWith("potentially different elements."))
    {
        #ignore
    }
    elseif ($line.EndsWith(" different elements."))
    {
        Echo $Line
        $diffResult += $line
        $diffResult += "`r`n"
    }
    elseif ($line.StartsWith("Found conflicts:"))
    {
        if ($line.StartsWith("Found conflicts: 0"))
        {
            #ignore if there is 0 conflicts
        }
        else
        {
            Echo $Line
            $diffResult += $line
            $diffResult += "`r`n"
        }

    }

}

Echo "Results:`r`n $diffresult"