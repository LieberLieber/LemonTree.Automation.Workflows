#Powershell sees curly brackets as codeblocks so use quotations marks "{}" or just write your guids without them
C:\"Program Files"\LieberLieber\LemonTree.Automation\LemonTree.Automation.exe publish --model model.eap --packagedirectory .\repo --componentguids "{c2791d98-4982-d2dd-449c-271ac0dbf1c2}","f7b4a94e-422c-94ee-1d44-ed33655e8d8e" --releasenotes "my notes"
echo Exitcode $LASTEXITCODE
pause