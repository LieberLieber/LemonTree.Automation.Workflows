param (
    [string]$xmlFilePath = $args[0]
)

# Check if an XML file path is provided as an argument
if (-not $xmlFilePath) {
    # If no argument is provided, find the first XML file in the current directory
    $xmlFiles = Get-ChildItem -Path . -Filter *.xml
    if ($xmlFiles -eq $null -or $xmlFiles.Count -eq 0) {
        Write-Host "No XML files found in the current directory."
        Exit
    } else {
        $xmlFilePath = $xmlFiles[0].FullName
    }
}

# Load the XML file
[xml]$xml = Get-Content -Path $xmlFilePath

# Define the XML namespaces
$ns = New-Object Xml.XmlNamespaceManager $xml.NameTable
$ns.AddNamespace("ns", "http://www.lieberlieber.com")

# Select all diagramPicture elements using the defined namespace
$diagramPictures = $xml.SelectNodes('//ns:diagramPictures/ns:diagramPicture', $ns)

# Output the count of found elements
Write-Host "Found $($diagramPictures.Count) Diagrams in $xmlFilePath."

# Create an HTML header
$html = '<html><head><title>Diagram Pictures</title></head><body>'

# Iterate through each diagram picture
foreach ($diagramPicture in $diagramPictures) {
    $guid = $diagramPicture.guid
    $diagramType = $diagramPicture.diagramType
    $name = $diagramPicture.diagramPictureA.name

    # Extract the CDATA content for diagramPictureA and diagramPictureB
    $cdata_a = $diagramPicture.diagramPictureA.InnerText
    $cdata_b = $diagramPicture.diagramPictureB.InnerText

    # Check if the CDATA sections are empty
    if (![string]::IsNullOrEmpty($cdata_a) -or ![string]::IsNullOrEmpty($cdata_b)) {
        # Create an HTML element for the diagram pictures
        $html += @"
        <div>
            <h2>Name: $name</h2>
            <p>GUID: $guid</p>
            <p>Type: $diagramType</p>
            <div style="display: flex;">
                <div style="flex: 1;">
                    <p>Diagram A:</p>
                    <img src='data:image/svg+xml;base64,$cdata_a' />
                </div>
                <div style="flex: 1;">
                    <p>Diagram B:</p>
                    <img src='data:image/svg+xml;base64,$cdata_b' />
                </div>
            </div>
        </div>
"@
    } else {
        Write-Host "Empty CDATA section found for diagram with name: $name"
    }
}

# Close the HTML page
$html += '</body></html>'

# Save the HTML page to a file
$html | Set-Content -Path 'output.html' -Force

Write-Host "HTML page has been generated and saved as 'output.html'."
