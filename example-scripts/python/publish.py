import os, subprocess
LT_AUTOMATION_BIN = os.path.normpath('C:/Program Files/LieberLieber/LemonTree.Automation')
command = [
                os.path.join(LT_AUTOMATION_BIN, 'LemonTree.Automation.exe'),
                "publish",
                "--model",  "model.eap",
                "--packagedirectory", ".\\repo", #double backslash for paths
                "--componentguids", "{c2791d98-4982-d2dd-449c-271ac0dbf1c2},f7b4a94e-422c-94ee-1d44-ed33655e8d8e",
                "--releasenotes", "My Notes",
            ]
p = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
out, err = p.communicate()
print(out.decode('utf-8'))
print(err.decode('utf-8'))
#Python expects a unsigned int here so our -1 exitcode needs special handling
if p.returncode == 4294967295:
    p.returncode = -1
print(f"Exitcode: {p.returncode}")