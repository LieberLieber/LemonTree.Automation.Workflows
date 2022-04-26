#getLTA.ps1
param(
    [parameter(Mandatory = $true)]
    [string]$LemonTreePackageURL
)
echo "Download LemonTree.Automtion from Repo"
while (Test-Path Alias:curl) {Remove-Item Alias:curl} #remove the alias binding from curl to Invoke-WebRequest
curl "$LemonTreePackageURL" --output LTA.zip -k
Expand-Archive LTA.zip -DestinationPath ..\LTA\ -Force
echo '::set-output name=LemonTreeAutomationExecutable::LTA\LemonTree.Automation.exe'