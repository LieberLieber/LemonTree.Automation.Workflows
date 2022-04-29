#Author: Daniel Siegl, LieberLieber Software GmbH
#The purpose of this script is to start lemontree with a model from different branch in cherry pick mode!
#Attention: the base and branchcopy of the file are collected from origin!
#Supported:
#.\example-scripts\powershell\CherryPicking.ps1 -Model DemoModel.eapx -Branch 70-test-for-discussion

param
(
        [Parameter(Mandatory = $false)][string] $filename = "..\DemoModel.eapx",
        [Parameter(Mandatory = $false)][string] $compareToBranch = "70-test-for-discussion",
        [Parameter(Mandatory = $false)][boolean] $conflicedFilter = 1 #if set to 1 it will add conflicted filters in the session
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

#Get the files from the remotes by commitid via http and curl - no LFS or not LFS handling needed
function Get-DownloadedFilename  
{
    param
    (
        [Parameter(Mandatory = $true)][string] $gitFilename,
        [Parameter(Mandatory = $true)][string] $commitID
    )
    process
    {
        $gitUri =  git config --get remote.origin.url
        $gitUri = $gitUri.Replace(".git","");
        $stripPathFilename = $commitID + "_"+[System.IO.Path]::GetFileName($gitFilename)
        $tempFilename = Join-Path -Path "$env:TEMP" -ChildPath "$stripPathFilename"
        $url = "$gitUri/raw/$baseId/$gitFilename"
        while (Test-Path Alias:curl) {Remove-Item Alias:curl} #remove the alias binding from curl to Invoke-WebRequest
        curl "$url" --output '$tempFilename' -L -k -s #-L follows the redirect to get the LFS file.
        return @($tempFilename);
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

# Get and output date from 3 branches/commmits involved.
$currentBranch = git branch --show-current
$baseId = git merge-base "origin/$compareToBranch" $currentBranch
$branchId = git log -n 1 "origin/$compareToBranch" --pretty=format:"%H"
echo "Currently activ Branch: $currentBranch"
echo "Base commit id: $baseId"
echo "$compareToBranch commit id: $branchId"

#Get the files from the remotes by commitid via http and curl - no LFS or not LFS handling needed
$baseFileName = Get-DownloadedFilename $gitFilename $baseId
$branchFileName = Get-DownloadedFilename $gitFilename $branchId
Echo "Base:   $baseFileName"
Echo "Branch: $branchFileName"

        #todo
        Set-Location $startDirectory
        exit
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



