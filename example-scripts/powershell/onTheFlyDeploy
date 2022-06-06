#Powershell sees curly brackets as codeblocks so use quotations marks "{}" or just write your guids without them
#assume license is in appdata
while (Test-Path Alias:curl) {Remove-Item Alias:curl} #remove the alias binding from curl to Invoke-WebRequest
curl "https://nexus.lieberlieber.com/repository/lemontree-release/LemonTree.Automation/LemonTree.Automation.Zip_Deploy.zip" --output LTA.zip -k
Expand-Archive LTA.zip -DestinationPath ..\LTA\ -Force
#'<license string goes here>' | Out-File -FilePath lta.lic #if you deploy the license on the fly
..\LTA\LemonTree.Automation.exe ConsistencyCheck --Model .\..\..\DemoModel.eapx #--License lta.lic if you deploy the license on the fly
echo Exitcode $LASTEXITCODE
pause