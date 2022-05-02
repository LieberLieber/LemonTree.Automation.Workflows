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
            $fileReference = $commitID+":"+$gitFilename
            #Echo $fileReference
            $pointer = git cat-file blob $fileReference
            #Echo "Head Pointer $pointer"
            $sha = ($pointer[1] -split(":"))[1]
          if($sha -ne $null){
            $shaPart1 = $sha.Substring(0,2)
            $shaPart2 = $sha.Substring(2,2)
            #echo "Model SHA: $sha"
            git cat-file --filters $fileReference | Out-Null
            $stripPathFilename = $commitID + "_"+[System.IO.Path]::GetFileName($gitFilename)
            $tempFilename = Join-Path -Path "$env:TEMP" -ChildPath "$stripPathFilename"
            copy ".git\lfs\objects\$shaPart1\$shaPart2\$sha" "$tempFilename"
            return @($tempFilename);
          }
          else{
            return @("NotFound");
          }

       
    }
}

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


$filename =".\DemoModel.eapx"

#convert the "windows path to a git path - works with realtive and absolute path. return -1 one on failure
$gitFilename = Get-GitMappedFilePaths($filename)
echo "filename parameter converted to git syntax $filename ==> $gitFilename"

#save the absolute path to the model before we change the working dir
$absoluteFilename = Get-Fullname $filename
Echo $absoluteFilename


$commitId = git rev-parse HEAD
Echo "Head CommitID $commitID"
$baseFileName = Get-DownloadedFilename $gitFilename $commitId
echo $baseFileName

#getrootids for the merge hint from the current model.
$modelRootIds = Get-ModelRootIds($absoluteFilename);

#build the parameter to call LemonTree with the merge hint
$mergeDecisionOverrides =""
$countRoots = 0
foreach($modelRootId in $modelRootIds) {
    if ($countRoots) #true when bigger than 0
    {
        $mergeDecisionOverrides += ","
    }
    $mergeDecisionOverrides += "$modelRootId"
    $mergeDecisionOverrides += ":B"
    $countRoots += 1
}
# Open LemonTree with Files. Commandline options https://help.lieberlieber.com/display/LT/VCS+Integration     
Echo "Starting LemonTree"
Echo $baseFileName
Echo $absoluteFilename
&'C:\Program Files\LieberLieber\LemonTree\LemonTree.exe' --merge=visual --base "$baseFileName" --theirs "$baseFileName" --mine "$absoluteFilename" --mergeDecisionOverrides="$mergeDecisionOverrides" -theirsAlias="HEAD"
exit 0