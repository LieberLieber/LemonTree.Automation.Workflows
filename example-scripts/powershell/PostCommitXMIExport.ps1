# Create the EA object
Echo "Create EA"
$ea = New-Object -ComObject "EA.Repository" -Strict
Echo "Created EA"
$ea.OpenFile("C:\github\LemonTree.Automation.Workflows\DemoModel.eapx")

$theProject = $ea.GetProjectInterface();
$theProject.ExportPackageXMI("{FA69A423-37E5-4c35-B982-0849B8820AB3}",22,0,-1,0,0,"C:\github\LemonTree.Automation.Workflows\export.xmi");
$ea.CloseFile()
$ea.Exit()