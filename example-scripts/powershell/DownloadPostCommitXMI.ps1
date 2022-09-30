#this script downloads xmi files from the artifact storage to be used by pipeline tools.
#typically it will run on an build agent like GitHub Actions


$gitcommitId = git rev-parse HEAD
$url = "https://nexus.lieberlieber.com/service/rest/v1/search?repository=xmi&name=$gitcommitId*"
Write-Host $url
$json = Invoke-RestMethod -Uri $url -Method Get

foreach ($url in $json.items.assets.downloadUrl) {
  $url = $url.Insert(4,"s")
  $file = $url.Substring($url.lastIndexOf('/') + 1)
  if($file.StartsWith($gitcommitId))
  {
    Write-Host $file
    $content = ((Invoke-WebRequest -Uri $url -Method Get) -replace "﻿")
    [IO.File]::WriteAllLines($file, $content)
  }
}
