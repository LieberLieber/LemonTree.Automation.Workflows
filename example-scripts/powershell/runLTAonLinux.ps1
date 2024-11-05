# Copyright (c) LieberLieber Software GmbH
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

#This scripts downloads and prepares Lemontree.Automation on a Linux machine.

$LemonTreePackageURL = "https://nexus.lieberlieber.com/repository/lemontree-release/LemonTree.Automation/LemonTree.Automation.Linux.Zip_latest.zip"
$LemonTreeZip = "LTA.zip"
$DestinationPath = "./LTA/"
$LemonTreeExe = "./LTA/lemontree.automation"

Write-Output "Downloading LemonTree.Automation from Nexus..."

try {
    # Attempt to download the file
    Invoke-WebRequest -URI $LemonTreePackageURL -OutFile $LemonTreeZip -ErrorAction Stop
    Write-Output "Download successful."
} catch {
    Write-Output "Error: Failed to download LemonTree.Automation. $_"
    exit 1
}

Write-Output "Extracting $LemonTreeZip..."

try {
    # Attempt to extract the archive
    Expand-Archive -Path $LemonTreeZip -DestinationPath $DestinationPath -Force -ErrorAction Stop
    Write-Output "Extraction successful."
} catch {
    Write-Output "Error: Failed to extract $LemonTreeZip. $_"
    exit 1
}

Write-Output "Setting executable permissions for $LemonTreeExe..."

try {
    # Attempt to set executable permissions
    chmod +x $LemonTreeExe
    Write-Output "Permissions set successfully."
} catch {
    Write-Output "Error: Failed to set executable permissions for $LemonTreeExe. $_"
    exit 1
}

Write-Output "LemonTreeAutomationExecutable=$LemonTreeExe"
exit 0
