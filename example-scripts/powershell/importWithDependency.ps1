
$mpmsfile ="Customer A-46e3f67f-4e87-c98e-129a-049eb063405f.mpms"
$emptyModel = "empty.eapx"
$newModelName ="Customer A.eapx"

$path = Get-Location
$mpmsfile = [System.IO.Path]::Combine($path,$mpmsfile) 

$componentFileName =""
foreach($line in [System.IO.File]::ReadLines($mpmsfile))
{
    if ($line.StartsWith("//{"))
    {
       $jsonContent = $line.Substring(2,$line.Length-2)| ConvertFrom-Json
       $count = 0
       foreach ($dependency in $jsonContent.Dependencies)
       {
        if ($count -ne 0)
        {
          $componentFileName +=","  
        }
        $count++

        $name = $dependency.name
        $target = $dependency.target.Substring(1,$dependency.target.length-2)
        $filename ="$name-$target.mpms"
    
        $componentFileName +=$filename
        
       }
       break
    }
}

if ($componentFileName)
{
    Copy-Item $emptyModel $newModelName -Force
    &"C:\Program Files\LieberLieber\LemonTree.Automation\LemonTree.Automation.exe" import --model $newModelName --Components $componentFileName
}