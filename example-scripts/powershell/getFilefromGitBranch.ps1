#The purpose of this script is to start lemontree with a model from different branch in cherry pick mode!
#Supported:
#.\example-scripts\powershell\CherryPicking.ps1 -Model DemoModel.eapx -Branch 70-test-for-discussion
param
(
        [Parameter(Mandatory = $false)][string] $filename = "..\DemoModel.eapx",
        [Parameter(Mandatory = $false)][string] $compareToBranch = "70-test-for-discussion"
)

#Check if the script is called from inside a git repo return -1 one on failure
function isGit
{
    process
    {
        $isGit = git rev-parse --is-inside-work-tree
        if (!$isGit)
        {
            echo "This script needs to be called from inside a git repo directory."
            exit -1
        }
    }
}

#convert the "windows path to a git path - works with realtive and absolute path. return -1 one on failure
function Get-GitMappedFilePaths  
{
    param
    (
        [Parameter(Mandatory = $true)][string] $filename
    )
    process
    {
        $gitFilename = git ls-files --full-name $filename
        if ([string]::IsNullOrEmpty($gitFilename))
        {
            echo "This filename parameter doesn't point to an existing file inside The repo directory."
            exit -1
        }
        return @($gitFilename);
    }
}

#main script
Echo "Model CherryPicking with LieberLieber LemonTree"
#check if the script is called inside a repo return -1 one on failure
isGit

#convert the "windows path to a git path - works with realtive and absolute path. return -1 one on failure
$gitFilename = Get-GitMappedFilePaths($filename)
echo "filename parameter converted to git syntax $filename ==> $gitFilename"

#set working directory temporaly to the root of the git repo
$startDirectory = Get-Location
$gitRootDir= git rev-parse --show-toplevel
Set-Location $gitRootDir





$currentBranch = git branch --show-current
echo "Currently activ Branch: $currentBranch"

##todo

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

