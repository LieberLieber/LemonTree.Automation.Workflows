# Copyright (c) LieberLieber Software GmbH
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

#This script will export the "mine" diagrams from a LemonTree xml diffreport into SVG files
#LemonTree.Automation needs to be called with --ReportIncludeDiagrams see: https://help.lieberlieber.com/LemonTree/LTA-Diff.html
#LemonTree.Automation.exe diff --base base.eapx --mine mine.eapx --theirs theirs.eapx --DiffReportFilename "DiffReport.xml" --ReportIncludeDiagrams

param (
    [string]$xmlFilePath = "DiffReport.xml"
)


[xml]$xmlContent = Get-Content -Path $xmlFilePath

# Define the XML namespaces
$ns = New-Object Xml.XmlNamespaceManager $xmlContent.NameTable
$ns.AddNamespace("ns", "http://www.lieberlieber.com")

# Select all diagramPicture elements using the defined namespace
$diagramPictures = $xmlContent.SelectNodes('//ns:diagramPictures/ns:diagramPicture', $ns)

# Output the count of found elements
Write-Host "Found $($diagramPictures.Count) Diagrams."

foreach ($diagramPicture in $diagramPictures) {
    $diagramGuid = $diagramPicture.guid
    if($diagramGuid){
        $cdata_b = $diagramPicture.diagramPictureB.InnerText

    # Check if the CDATA section is empty
    if (![string]::IsNullOrEmpty($cdata_b)) {
                $qualifiedName = $diagramPicture.diagramPictureB.qualifiedName
                write-host $qualifiedName
                $fileGuid = $diagramGuid.Replace('{','').Replace('}','')
                $filename = "$fileGuid.svg"
                write-output "$qualifiedName ==> $filename"
                $cdata_b | %{[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($_))}|Set-Content -Encoding UTF8 -Path $filename
            }
        }
    }


