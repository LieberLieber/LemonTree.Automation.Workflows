#getLTA.ps1
param(
    [parameter(Mandatory = $true)]
    [string]$LemonTreePackageURL,

    [parameter(Mandatory = $true)]
    [string]$License
)

echo "Download LemonTree.Automtion from Repo"
echo "***$License**"
while (Test-Path Alias:curl) {Remove-Item Alias:curl} #remove the alias binding from curl to Invoke-WebRequest
curl "$LemonTreePackageURL" --output LTA.zip -k
Expand-Archive LTA.zip -DestinationPath .\LTA\ -Force

IF([string]::IsNullOrWhiteSpace($License)) {            
    echo "No License provided."         
} else {            
    echo "Create License File ${License}"
    $License | Out-File -FilePath lta.lic #if you deploy the license on the fly
}  

echo '::set-output name=LemonTreeAutomationExecutable::.\LTA\LemonTree.Automation.exe'