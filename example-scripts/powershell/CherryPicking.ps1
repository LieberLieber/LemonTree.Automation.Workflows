#CherryPicking.ps1
#.\CherryPicking.ps1 -Model ..\..\DemoModel.eapx
#.\CherryPicking.ps1 -Model C:\GitHub\LemonTree.Automation.Workflows\DemoModel.eapx

#Comment this in to run in x86 space with Jet Driver
#$script = Start-Job -ScriptBlock {

param(
    [parameter(Mandatory = $false)]
    [string]$Model,

    [parameter(Mandatory = $false)]
    [string]$Branch
)

function Get-Fullname {
  param($filename)
  process{
      if (Test-Path $filename) {(Get-Item $fileName).FullName} 
       }
  }

function DownloadModelfromBranch{
  param($branchname)
  process{
  #this is a workaround for now to see if the rest works.
  while (Test-Path Alias:curl) {Remove-Item Alias:curl} #remove the alias binding from curl to Invoke-WebRequest
   curl "https://github.com/LieberLieber/LemonTree.Automation.Workflows/raw/77-auto-deploy-lemontree-automation-demo-via-zip-file/DemoModel.eapx" --output 'DemoModel_Branch.eapx' -k
   $pointer = git cat-file blob 'DemoModel_Branch.eapx'
          $sha = ($pointer[1] -split(":"))[1]
          if($sha -ne $null){
            $shaPart1 = $sha.Substring(0,2)
            $shaPart2 = $sha.Substring(2,2)
            echo "Model SHA: $sha"
            git cat-file --filters 'DemoModel_Branch.eapx' | Out-Null
            copy ".git\lfs\objects\$shaPart1\$shaPart2\$sha" "'DemoModel_Branch_Inflated.eapx'
            echo "::set-output name=result::downloaded"}
  }
}

function Get-ModelRootIds  {
        param($absoluteModel)
        $conn = New-Object System.Data.OleDb.OleDbConnection("Provider=Microsoft.ACE.OLEDB.12.0; Data Source='$absoluteModel'") 
        $conn.Open()
    
        $cmd = $conn.CreateCommand()
        $cmd.CommandText ="select ea_guid from t_package where parent_id = 0"
        $reader = $cmd.ExecuteReader()   

        $results = @()
        while ($reader.Read())
        {
            $row = @{}
            for ($i = 0; $i -lt $reader.FieldCount; $i++)
            {
                $row[$reader.GetName($i)] = $reader.GetValue($i)
            }
            $results += new-object psobject -property $row  
                  
        }
        $conn.Close();
        return @($results)
}

if ((Test-Path -Path $Model -PathType Leaf)) {
     try {
        #model exists we can party
        echo "Before"
        $absoluteModel = Get-Fullname($Model)
        echo $Model
        echo "after"
        echo $absoluteModel

       
        DownloadModelfromBranch($Branch)

        $results = Get-ModelRootIds($absoluteModel);
       
        $results

       &'C:\Program Files\LieberLieber\LemonTree\LemonTree.exe' -merge --theirs 'DemoModel_Branch.eapx' --mine '$absoluteModel'

     }
     catch {
         throw $_.Exception.Message
     }
 }
# If the file doesn't exists, show the message and do nothing.
 else {
     Write-Host "Model doesn't exist!"
 }

#Comment this in to run in x86 space with Jet Driver
# } -RunAs32
#'$script | Wait-Job | Receive-Job
