 Install-Module -Name PSSQLite #needs admin rights to be installed
 $db = "C:\GitHub\LemonTree.PCS.Demo\Model.qeax"
 $sql  ="" #just for better readability
 $sql +="select t_diagram.Name as DiagramName, 'DiagramObject Color' as ColorType, Count(*) as NumberViolation"
 $sql +=" from (t_diagramobjects"
 $sql +=" inner join t_object on (t_diagramobjects.Object_ID = t_object.Object_ID))"
 $sql +=" inner join t_diagram on (t_diagramobjects.Diagram_ID = t_diagram.Diagram_ID)"
 $sql +=" where t_diagramobjects.ObjectStyle NOT like '%BCol=-1%' and t_diagramobjects.ObjectStyle  like '%BCol=%'"
 $sql +=" Group by t_diagram.Name, ColorType"
 $sql +=" Order by NumberViolation DESC"
 $result = Invoke-SqliteQuery -DataSource $db -Query $sql
 if ($result) {
    Write-Output "DiagramObject Color violations"  
    Write-Output $result 
    Exit 1 #if used in a pipeline it should fail
 } else{ 
    Write-Output "No DiagramObject Color violations"
    Exit 0 #obsolete but makes it easier to read
 }
