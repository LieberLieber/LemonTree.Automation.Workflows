# Copyright (c) LieberLieber Software GmbH
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

#this scripts downloads and prepares Lemontree.Automation on a Linux machine.

$LemonTreePackageURL = "https://nexus.lieberlieber.com/repository/lemontree-release/LemonTree.Automation/LemonTree.Automation.Linux.Zip_latest.zip"

Write-Output "Download LemonTree.Automtion from Repo"
Invoke-WebRequest -URI "$LemonTreePackageURL" -OutFile "LTA.zip"
Expand-Archive "LTA.zip" -DestinationPath ".\LTA\" -Force

$LemonTreeExe = "./LTA/lemontree.automation"
#workaround because github artifacts logic doesn't maintain properties
chmod +x $LemonTreeExe            

Write-Output "LemonTreeAutomationExecutable=$LemonTreeExe"

exit 0
