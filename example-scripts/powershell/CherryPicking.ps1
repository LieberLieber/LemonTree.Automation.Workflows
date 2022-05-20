#CherryPicking.ps1
#Author: Daniel Siegl, LieberLieber Software GmbH
#The purpose of this script is to start lemontree with a model from different branch in cherry pick mode!
#Attention: the base and branchcopy of the file are collected from origin!
#Supported:
#.\example-scripts\powershell\CherryPicking.ps1 -Model DemoModel.eapx -Branch 70-test-for-discussion

param
(
        [Parameter(Mandatory = $true)][string] $Model = "..\DemoModel.eapx",
        [Parameter(Mandatory = $true)][string] $Branch = "70-test-for-discussion",
        [Parameter(Mandatory = $false)][string] $ModelRootIds = $null#,
        #for future use - filters are not supported by lemontree commandline - just by Session Files
        #[Parameter(Mandatory = $false)][boolean] $conflicedFilter = 1 #if set to 1 it will add conflicted filters in the session
)

function Get-Fullname 
{
    param
    (
        [Parameter(Mandatory = $true)][string]$filename
    )
    process
    {
        if (Test-Path $filename) 
        {
            (Get-Item $fileName).FullName
        } 
    }
}


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
        $stripPathFilename = $commitID + "_"+[System.IO.Path]::GetFileName($gitFilename)
        $tempFilename = Join-Path -Path "$env:TEMP" -ChildPath "$stripPathFilename"

        echo "Commit ID: $commitID"
        #git fetch origin $commitID
        $pointer = git cat-file blob ("$commitID"+":"+"$gitFilename")
        $sha = ($pointer[1] -split(":"))[1]
        $shaPart1 = $sha.Substring(0,2)
        $shaPart2 = $sha.Substring(2,2)
        echo "Model SHA: $sha"
        git cat-file --filters ("$commitID"+":"+"$gitFilename") | Out-Null
        copy ".git\lfs\objects\$shaPart1\$shaPart2\$sha" "$tempFilename"
    }
}

function Get-ModelRootIds  
{
    param
    (
        [Parameter(Mandatory = $true)][string] $absoluteModel
    )
    process
    {
        #Comment needed for 32 bit jet driver - 64 bit ACE is not all computers.
        #$script = Start-Job -ScriptBlock {       
            #x64 db connection
            $conn = New-Object System.Data.OleDb.OleDbConnection("Provider=Microsoft.ACE.OLEDB.12.0; Data Source='$absoluteModel'") 

            #x86 db connection
            #$conn = New-Object System.Data.OleDb.OleDbConnection("Provider=Microsoft.Jet.OLEDB.4.0; Data Source='$absoluteModel'") 

            $conn.Open()

            $cmd = $conn.CreateCommand()
            $cmd.CommandText ="select ea_guid from t_package where parent_id = 0"
            $reader = $cmd.ExecuteReader()   
            $results = @()
            while ($reader.Read())
            {
                $results += $reader.GetValue(0)        
            }
            $conn.Close();
        #} -RunAs32
        #$script | Wait-Job | Receive-Job
        return @($results);
        #Comment this in to run in x86 space with Jet Driver
    }
}

#turn on strict mode
Set-StrictMode -Version Latest

#map to internal variables
$filename = $Model
$compareToBranch = $Branch

#main script
Echo "Model CherryPicking with LieberLieber LemonTree"
#check if the script is called inside a repo return -1 one on failure
isGit

#convert the "windows path to a git path - works with realtive and absolute path. return -1 one on failure
$gitFilename = Get-GitMappedFilePaths($filename)
echo "filename parameter converted to git syntax $filename ==> $gitFilename"

#save the absolute path to the model before we change the working dir
$absoluteFilename = Get-Fullname $filename

#set working directory temporaly to the root of the git repo
$startDirectory = Get-Location
$gitRootDir= git rev-parse --show-toplevel
Set-Location $gitRootDir

# Get and output date from 3 branches/commmits involved.
$currentBranch = git branch --show-current
$baseId = git merge-base "origin/$compareToBranch" $currentBranch
$branchId = git log -n 1 "origin/$compareToBranch" --pretty=format:"%H"

echo "Currently activ Branch: $currentBranch"
echo "Commit id: $baseId for base"
echo "Commit id: $branchId for $compareToBranch"

#Get the files from the remotes by commitid via http and curl - no LFS or not LFS handling needed
echo "Start Downloading ..."
$baseFileName = Get-DownloadedFilename $gitFilename $baseId
$branchFileName = Get-DownloadedFilename $gitFilename $branchId
Echo "Finished downloading."
Echo "Base:   $baseFileName"
Echo "Branch: $branchFileName"
#todo: thedownload of the branch file seems to be wrong.


#getrootids for the merge hint from the current model.
$modelRootArray = $null
if($ModelRootIds -eq ""){
    $modelRootArray = Get-ModelRootIds($absoluteFilename);
}
else {
    $modelRootArray = $ModelRootIds.Split(',')
}

#build the parameter to call LemonTree with the merge hint
$mergeDecisionOverrides= $null
$modelRootArray | ForEach-Object -Begin {
    $mergeOverrides = @()
} -Process {
    #Append model B as source to each root
    $mergeOverrides += ("$_"+":B")
} -End {
    $mergeDecisionOverrides = $mergeOverrides -join ','
}

# Open LemonTree with Files. Commandline options https://help.lieberlieber.com/display/LT/VCS+Integration     
$LemonTreeCommando = "-merge --base '$baseFileName' --theirs '$branchFileName' --mine '$absoluteFilename' --out '$absoluteFilename' --mergeDecisionOverrides='$mergeDecisionOverrides'"
Echo "Starting LemonTree with $LemonTreeCommando"
&'C:\Program Files\LieberLieber\LemonTree\LemonTree.exe' --merge=visual --base "$baseFileName" --theirs "$branchFileName" --mine "$absoluteFilename" --mergeDecisionOverrides="$mergeDecisionOverrides" --theirsAlias="$compareToBranch"
 
Set-Location $startDirectory
exit 0

