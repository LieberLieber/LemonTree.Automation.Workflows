ECHO FOO
START CMD /C "ECHO Script is running && PAUSE"
powershell.exe -ExecutionPolicy Bypass -File "%~dp0mpmsmerge.ps1" %* >> %~dp0mpmsmerge-output.log
