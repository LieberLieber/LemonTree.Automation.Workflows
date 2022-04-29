git rev-parse --is-inside-work-tree

$filename = "..\..\DemoModel.eapx"
$gitFilename = git ls-files --full-name $filename
echo "$filename ==> $gitFilename"

#getabsolutefilename

$compareToBranch ="main"

$startDirectory = Get-Location
$gitRootDir= git rev-parse --show-toplevel
Set-Location $gitRootDir

#mapit realtive to git repo.

$currentBranch = git branch --show-current

$baseId = git merge-base $compareToBranch $currentBranch
echo $baseId
$gitUri =  git config --get remote.origin.url
echo $gitUri
$gitUri = $gitUri.Replace(".git","");
echo $gitUri
$tempFilename = [System.IO.Path]::GetTempFileName() +".eapx"
echo $tempFilename

$url = "$gitUri/raw/$baseId/$gitFilename"
echo "Downloading from $url"
while (Test-Path Alias:curl) {Remove-Item Alias:curl} #remove the alias binding from curl to Invoke-WebRequest
curl "$url" --output "$tempFilename" -L -k #-L follows the redirect to get the LFS file.

Set-Location $startDirectory