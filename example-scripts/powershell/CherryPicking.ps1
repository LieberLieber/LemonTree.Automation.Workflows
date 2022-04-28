#CherryPicking.ps1
#.\CherryPicking.ps1 -Model ..\..\DemoModel.eapx
#.\CherryPicking.ps1 -Model C:\GitHub\LemonTree.Automation.Workflows\DemoModel.eapx

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

if ((Test-Path -Path $Model -PathType Leaf)) {
     try {
        #model exists we can party
 
        $absoluteModel = Get-Fullname($Model)
        echo "Before"
        echo $Model
            
        echo "after"
        echo $absoluteModel

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

        $results

     }
     catch {
         throw $_.Exception.Message
     }
 }
# If the file already exists, show the message and do nothing.
 else {
     Write-Host "Model doesn't exist!"
 }

