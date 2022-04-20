$json = Invoke-RestMethod -Uri https://nexus.lieberlieber.com/service/rest/v1/components?repository=lemontree-component -Method Get
foreach ($url in $json.items.assets.downloadUrl) {
  $url = $url.Insert(4,"s")
  $file = $url.Substring($url.lastIndexOf('/') + 1)
  Write-Host $file
  Invoke-RestMethod -Uri $url -Method Get > $file
}
