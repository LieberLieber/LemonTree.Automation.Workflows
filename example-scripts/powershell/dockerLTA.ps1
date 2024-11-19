# Copyright (c) LieberLieber Software GmbH
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

#this is not a finished script - it is just the basic info to get you started using LemonTree.Automation deployed as a Docker Container into your pipeline.
#sample models can be found on computers with LemonTree Desktop installed: C:\ProgramData\LieberLieber\LemonTree\Examples

#as is this script is built to run on a Windows Desktop with Docker Desktop installed.

$ltaLicenses = "$(Get-Location)/licenses"
$ltaData ="$(Get-Location)/data"

#prepare mapping directories for docker mapping
New-Item -ItemType Directory -Force -Path "$ltaLicenses"
New-Item -ItemType Directory -Force -Path "$ltaData"

#copy my locallicense to the folder - pls use yours as they fit
Copy-Item -Path "C:\tmp\license000_ANY.lic" -Destination "$ltaLicenses" -Force 
Copy-Item -Path "C:\ProgramData\LieberLieber\LemonTree\Examples\A.qeax" -Destination "$ltaData" -Force 
Copy-Item -Path "C:\ProgramData\LieberLieber\LemonTree\Examples\B.qeax" -Destination "$ltaData" -Force 
Copy-Item -Path "C:\ProgramData\LieberLieber\LemonTree\Examples\Base.qeax" -Destination "$ltaData" -Force 

docker stop ltacli
docker rm ltacli
docker run -id --name ltacli -v "${ltaData}:/data" -v "${ltaLicenses}:/app/licenses" nexus.lieberlieber.com:5000/lieberlieber/lemontree.automation:latest
	
docker exec -i ltacli ./lemontree.automation diff --license /app/licenses/ --base /data/Base.qeax --theirs /data/A.qeax --mine /data/B.qeax
 

