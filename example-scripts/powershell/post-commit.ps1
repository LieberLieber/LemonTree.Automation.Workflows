#powershell script to run from the post-commit file in ./git/hooks
#It will publish an XMI file to in our case Nexus to be used by pipelinetools that handle EA XMI
#to embedded this script in your hook file simply add the next line to the post-commit file.
#c:/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -ExecutionPolicy RemoteSigned -File 'example-scripts\powershell\post-commit.ps1'

#Parameters
#need to be setup for your repo
$eaModel = "DemoModel.eapx"

#prepare environment
Write-Output "post-commit publish of XMI to Nexus"
$repoPath = git rev-parse --show-toplevel
$modelfile = Join-Path -Path $repoPath  -ChildPath $eaModel
$gitcommitId = git rev-parse HEAD

#prepare upload to Artifact Provider
$file =  Join-Path -Path $repoPath  -ChildPath "..\nexus.inf"
$file = [System.IO.Path]::GetFullPath($file)
#not the savest way on earth but a pragmatic solution for the sake of this demo
$SecureCredential = Get-Content "$file" | ConvertTo-SecureString
$login = (New-Object PSCredential "username",$SecureCredential).GetNetworkCredential().Password
$targetUrl = "https://nexus.lieberlieber.com/repository/xmi/"

#start EA and load the Model
Write-Output "Create EA"
$ea = New-Object -ComObject "EA.Repository" -Strict
Write-Output "Created EA Instance"
Write-Output "Model File : $modelfile"
Write-Output "Open Model"
$ea.OpenFile($modelfile)
$theProject = $ea.GetProjectInterface();

#XMI Export one file per Model Root
Write-Output "Running XMI Export"
foreach($model in $ea.models) 
{ 
    $modelName = $model.Name
    $packageGuid = $model.PackageGUID
    #we don't want to upload the LemonTree.Components Stuff
    if (-Not $modelName.Equals("MPMS Specification and Configuration"))
    {
        $xmiFileName = "$gitcommitId-$modelName.xmi"
        $xmiFile = Join-Path -Path $repoPath  -ChildPath "$xmiFileName"
        Write-Output "Exporting $modelName with $packageGuid  to $xmiFile"
        $result = $theProject.ExportPackageXMI("$packageGuid",22,0,-1,0,0,$xmiFile);
         
        Write-Output "Uploading $xmiFile to Nexus: $targetUrl"
        #it only works like this for me with curl.exe
        &curl.exe "-u$login" -T "$xmiFile" "$targetUrl"
    }
}
Write-Output "Finished XMI Export"

#cleanup
$ea.CloseFile()
$ea.Exit()
Write-Output "Disposed EA"
Write-Output "Finished"