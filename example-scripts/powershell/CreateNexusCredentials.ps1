param
(
        [Parameter(Mandatory = $true, HelpMessage="Enter: 'Username:Password'")][string] $Credential
)
$repoPath = git rev-parse --show-toplevel
$file =  Join-Path -Path $repoPath  -ChildPath "..\nexus.inf"
$file = [System.IO.Path]::GetFullPath($file)
echo $file
$Credential | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString | Out-File "$file"