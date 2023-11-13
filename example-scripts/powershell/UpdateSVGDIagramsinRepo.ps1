# Copyright (c) LieberLieber Software GmbH
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

#This script will update the "mine" diagrams from a LemonTree xml diffreport into SVG files

#Check if the Folder Exists 
$folderPath = ".\svg"
if (Test-Path $folderPath) {
    Write-Output "Folder $folderPath exists"
} else {
    Write-Output "Folder $folderPath does not exist, we create it "
    New-Item -ItemType Directory -Force -Path $folderPath
}

#delete all SVG files from the Folder - so deletion of diagrams is also reflected in git. existing diagrams will be recreated anyway.
$filesSVG =	$folderPath+"\*.svg"
Write-Output "deleting files $filesSVG"
Remove-Item "$filesSVG"

#create SVG Files 
&'C:\Program Files\LieberLieber\LemonTree.Automation\LemonTree.Automation.exe' SVGExport --Model .\DemoModel.eapx --DiagramDirectory '.\svg'

#git commit
git add -A
git commit -m "LemonTree.Automation SVG Update"

#git push
#git push