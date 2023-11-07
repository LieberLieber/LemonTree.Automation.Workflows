# Copyright (c) LieberLieber Software GmbH
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

#This script will export the mine diagrams from a LemonTree xml diffreport into a SVG files

param (
    [string]$xmlFilePath = "DiffReport.xml"
)

$xmlContent = Get-Content -Path $xmlFilePath | Out-String
select-xml -Content $xmlContent -xpath "//diagramPictures/diagramPicture" | foreach {
    $diagramGuid = $_.node.guid
    if($diagramGuid ){
        select-xml -Content $xmlContent -xpath "//diagramPictures/diagramPicture[@guid='$diagramGuid']/diagramPictureB" | foreach {
            #check if cdata exists
            if ($_.node.InnerText)
            {
                $qualifiedName = $_.node.qualifiedName
                $fileGuid = $diagramGuid.Replace('{','').Replace('}','')
                $filename = "$fileGuid.svg"
                write-output "$qualifiedName ==> $filename"
                $_.node.InnerText | %{[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($_))}|Set-Content -Encoding UTF8 -Path $filename
            }
        }
    }}
