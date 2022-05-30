#Powershell sees curly brackets as codeblocks so use quotations marks "{}" or just write your guids without them
$componentGuids =""

$componentFiles = Get-ChildItem *.mpms
$count = 0
foreach ($componentFile in $componentFiles)
{
  if ($count -ne 0)
  {
    $componentGuids+=","
  }
  #take the guid via substring from e.g "Customer A-46e3f67f-4e87-c98e-129a-049eb063405f"
  $newGuid = $componentFile.BaseName.Substring($componentFile.BaseName.Length-36,36);
  $componentGuids +=  $newGuid
  $count++
}

echo "Exporting Components: $componentGuids"
C:\"Program Files"\LieberLieber\LemonTree.Automation\LemonTree.Automation.exe publish --model model.eapx --packagedirectory .\ --componentguids "$componentGuids" --releasenotes "my notes"
echo Exitcode $LASTEXITCODE
pause