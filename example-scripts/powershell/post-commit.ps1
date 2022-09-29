Write-Output "post-commit publish of XMI to Nexus"
#$curl = "C:\Program Files\Git\mingw64\bin\curl.exe"
$mypath = $MyInvocation.MyCommand.Path
Write-Output "Create EA"
$ea = New-Object -ComObject "EA.Repository" -Strict
$repoPath = git rev-parse --show-toplevel
$modelfile = Join-Path -Path $repoPath  -ChildPath "DemoModel.eapx"
$gitcommitId = git rev-parse HEAD
$xmiFileName = "$gitcommitId.xmi"
$xmiFile = Join-Path -Path $repoPath  -ChildPath "$xmiFileName"
Write-Output "Model File : $modelfile"
Write-Output "XMI File : $xmiFile"

Write-Output "Created EA"
$ea.OpenFile($modelfile)

$theProject = $ea.GetProjectInterface();
Write-Output "Running XMI Export"
$result = $theProject.ExportPackageXMI("{FA69A423-37E5-4c35-B982-0849B8820AB3}",22,0,-1,0,0,$xmiFile);
Write-Output "Finsihed XMI Export"
$ea.CloseFile()
$ea.Exit()
Write-Output "Disposed EA"
$file =  Join-Path -Path $repoPath  -ChildPath "..\nexus.inf"
$file = [System.IO.Path]::GetFullPath($file)
$SecureCredential = Get-Content "$file" | ConvertTo-SecureString
$login = (New-Object PSCredential "username",$SecureCredential).GetNetworkCredential().Passwor
$targetUrl = "https://nexus.lieberlieber.com/repository/xmi/"
Write-Output "Uploading $xmiFile to Nexus: $targetUrl"
while (Test-Path Alias:curl) {Remove-Item Alias:curl} #remove the alias binding from curl to Invoke-WebRequest
&curl "-u$login" -T "$xmiFile" "$targetUrl"
Write-Output "Uploaded to Nexxus" 