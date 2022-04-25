#Powershell sees curly brackets as codeblocks so use quotations marks "{}" or just write your guids without them
while (Test-Path Alias:curl) {Remove-Item Alias:curl} #remove the alias binding from curl to Invoke-WebRequest
curl "https://nexus.lieberlieber.com/repository/lemontree-pipeline-tools/templatemodels/empty.qeax" --output empty.qeax -k
C:\"Program Files"\LieberLieber\LemonTree.Automation\LemonTree.Automation.exe merge --theirs .\empty.qeax --mine ..\..\DemoModel.eapx --out .\DemoModelConverted.qeax
echo Exitcode $LASTEXITCODE
pause