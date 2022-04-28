#CherryPicking.ps1
#Supported:
#.\example-scripts\powershell\CherryPicking.ps1 -Model DemoModel.eapx -Branch 70-test-for-discussion


# Currently not supported - script needs to be run next to the model.
#.\CherryPicking.ps1 -Model ..\..\DemoModel.eapx
#.\CherryPicking.ps1 -Model C:\GitHub\LemonTree.Automation.Workflows\DemoModel.eapx 

#Comment this in to run in x86 space with Jet Driver
#$script = Start-Job -ScriptBlock {

param(
    [parameter(Mandatory = $true)]
    [string]$Model,

    [parameter(Mandatory = $true)]
    [string]$Branch
)

function Get-Fullname {
  param($filename)
  process{
      if (Test-Path $filename) {(Get-Item $fileName).FullName} 
       }
  }

function DownloadModelfromBranch{
 Param
    (
        [Parameter(Mandatory = $true)]  $filename,
        [Parameter(Mandatory = $true)]  $Branch,
        [Parameter(Mandatory = $true)] $tempFilename
    )

  process{
  Echo "Inside Method filename $filename"
  Echo "Inside Method Branch $Branch"
  Echo "Inside Method tempFilename $tempFilename"
  $url = "https://github.com/LieberLieber/LemonTree.Automation.Workflows/raw/$Branch/$filename"
  echo "***"
  echo $url
  echo "***"

  echo "curl '$url' --output '$tempFilename' -L -k"
  #this is a workaround for now to see if the rest works.
  while (Test-Path Alias:curl) {Remove-Item Alias:curl} #remove the alias binding from curl to Invoke-WebRequest
  curl "$url" --output '$tempFilename' -L -k #-L follows the redirect to get the LFS file.
   
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
        $tempFilename = "$Model"
        echo $tempFilename
        $absolutetempFilename = "$env:TEMP\$tempFilename"
        echo $absolutetempFilename
      
        echo "Branch $Branch"
        DownloadModelfromBranch $Model $Branch $absolutetempFilename

        $results = Get-ModelRootIds($absoluteModel);
       
        $results

       &'C:\Program Files\LieberLieber\LemonTree\LemonTree.exe' -merge --base "$absolutetempFilename" --theirs "$absolutetempFilename" --mine "$absoluteModel" 

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
