import os, subprocess
LT_AUTOMATION_BIN = os.path.normpath('C:/Program Files/LieberLieber/LemonTree.Automation')
command = [
                os.path.join(LT_AUTOMATION_BIN, 'LemonTree.Automation.exe'),
                "diff",
                "--base",  "base.eapx",
                "--mine", "mine.eapx",
                "--theirs", "theirs.eapx",
                "--sfs", "sessionfile.ltsfs"
            ]
p = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
out, err = p.communicate()
print(out.decode('utf-8'))
print(err.decode('utf-8'))
#Python expects a unsigned int here so our -1 exitcode needs special handling
if p.returncode == 4294967295:
    p.returncode = -1
print(f"Exitcode: {p.returncode}")