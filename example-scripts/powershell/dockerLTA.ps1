# Copyright (c) LieberLieber Software GmbH
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

#this is not a finished script - it is just the basic info to get you started using LemonTree.Automation deployed as a Docker Container into your pipeline.

docker rm ltacli
docker run -itd --name ltacli `
    -v "$(Get-Location)\data:/data" `
    -v "$(Get-Location)\licenses:/app/licenses" `
    nexus.lieberlieber.com:5000/lieberlieber/lemontree.automation:latest
	
docker exec -it ltacli ./lemontree.automation diff --license /app/licenses/ --base /data/Base.qeax --theirs /data/A.qeax --mine /data/B.qeax
 

