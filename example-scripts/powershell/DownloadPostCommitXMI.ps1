#this script downloads xmi files from the artifact storage to be used by pipeline tools.

$gitcommitId = git rev-parse HEAD
$json = Invoke-RestMethod -Uri https://nexus.lieberlieber.com/service/rest/v1/components?repository=xmi -Method Get
foreach ($url in $json.items.assets.downloadUrl) {
  $url = $url.Insert(4,"s")
  $file = $url.Substring($url.lastIndexOf('/') + 1)
  if($file.StartsWith($gitcommitId))
  {
    Write-Host $file
    $content = ((Invoke-RestMethod -Uri $url -Method Get) -replace "﻿")
    [IO.File]::WriteAllLines($file, $content)
  }
}
