Echo "Create EA"
$mypath = $MyInvocation.MyCommand.Path
Write-Output "Path of the script : $mypath"
$ea = New-Object -ComObject "EA.Repository" -Strict
$repoPath = git rev-parse --show-toplevel
$modelfile = Join-Path -Path $repoPath  -ChildPath "DemoModel.eapx"
$xmiFile = Join-Path -Path $repoPath  -ChildPath "export.xmi"
Write-Output "Model File : $modelfile"
Write-Output "XMI File : $xmiFile"

Write-Output "Created EA"
$ea.OpenFile($modelfile)

$theProject = $ea.GetProjectInterface();
Write-Output "Running XMI Export"
$theProject.ExportPackageXMI("{FA69A423-37E5-4c35-B982-0849B8820AB3}",22,0,-1,0,0,$xmiFile);
Write-Output "Finsihed XMI Export"
$ea.CloseFile()
$ea.Exit()
Write-Output "Disposed EA"