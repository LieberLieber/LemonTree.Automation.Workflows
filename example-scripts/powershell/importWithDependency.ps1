$mpmsfile ="C:\LemonTreeTestData\publishExistingDemo\Customer A-46e3f67f-4e87-c98e-129a-049eb063405f.mpms"
Echo ""
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

        $filename =""
        $filename +=$dependency.name
        $filename +="-"
        $filename +=$dependency.target
        $filename +=".mpms"
        
        $componentFileName +=$filename
        
       }
       break
    }
}
$componentFileName