param (
    [string]$xmlFilePath = $args[0],
    [string]$outputDirectory = 'output_images'
)

# Check if an XML file path is provided as an argument
if (-not $xmlFilePath) {
    $xmlFiles = Get-ChildItem -Path . -Filter *.xml

    if ($xmlFiles -eq $null -or $xmlFiles.Count -eq 0) {
        Write-Host "No XML files found in the current directory."
        Exit
    } else {
        $xmlFilePath = $xmlFiles[0].FullName
    }
}

Write-Host "Using XML file: $xmlFilePath"

try {
    [xml]$xml = Get-Content -Path $xmlFilePath
} catch {
    Write-Host "Failed to load the XML file: $_"
    Exit
}

# Ensure the output directory exists
if (-not (Test-Path -Path $outputDirectory)) {
    New-Item -ItemType Directory -Path $outputDirectory -Force > $null
}

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
    $nameB = $diagramPicture.diagramPictureB.name

    # Extract the CDATA content for diagramPictureA and diagramPictureB
    $cdata_a = $diagramPicture.diagramPictureA.InnerText
    $cdata_b = $diagramPicture.diagramPictureB.InnerText

    # Check if the CDATA sections are empty
    if (![string]::IsNullOrEmpty($cdata_a) -or ![string]::IsNullOrEmpty($cdata_b)) {
        # Generate unique filenames for the images
        $filename_a = Join-Path -Path $outputDirectory -ChildPath "$name-DiagramA.svg"
        $filename_b = Join-Path -Path $outputDirectory -ChildPath "$nameB-DiagramB.svg"

        # Save the images as files
        if (![string]::IsNullOrEmpty($cdata_a)) {
            [System.Convert]::FromBase64String($cdata_a) | Set-Content -Path $filename_a -Encoding Byte
        }
        if (![string]::IsNullOrEmpty($cdata_b)) {
            [System.Convert]::FromBase64String($cdata_b) | Set-Content -Path $filename_b -Encoding Byte
        }

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
Write-Host "Images saved in $outputDirectory."
