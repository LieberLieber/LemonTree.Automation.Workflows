$filename = "..\..\DemoModel.eapx"
$compareToBranch ="main"

$currentBranch = git branch --show-current
$baseId = git merge-base $compareToBranch $currentBranch
echo $baseId
$gitUri =  git config --get remote.origin.url
echo $gitUri
$gitUri = $gitUri.Replace(".git","");
echo $gitUri
$tempFilename = [System.IO.Path]::GetTempFileName() +".eapx"
echo $tempFilename

echo "Downloading from $url"
while (Test-Path Alias:curl) {Remove-Item Alias:curl} #remove the alias binding from curl to Invoke-WebRequest
curl "$url" --output "$tempFilename" -L -k #-L follows the redirect to get the LFS file.

