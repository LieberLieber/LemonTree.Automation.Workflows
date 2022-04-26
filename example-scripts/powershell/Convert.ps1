#Powershell sees curly brackets as codeblocks so use quotations marks "{}" or just write your guids without them
while (Test-Path Alias:curl) {Remove-Item Alias:curl} #remove the alias binding from curl to Invoke-WebRequest
curl -s "https://nexus.lieberlieber.com/repository/lemontree-pipeline-tools/templatemodels/empty.qeax" --output "empty.qeax" -k

$files = Get-ChildItem -Filter *.eap?
$files | ForEach-Object -Process {
  $name=".\"+$_.Name
  $newName=".\"+$_.BaseName+".qeax"
  Write-Host "Converting $name to $newName"
  &"C:\Program Files\LieberLieber\LemonTree.Automation\LemonTree.Automation.exe" merge --theirs .\empty.qeax --mine $name --out $newName
  echo "Exitcode $LASTEXITCODE"
}

Remove-Item .\empty.qeax
pause
