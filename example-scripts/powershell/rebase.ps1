$env:GIT_EDITOR = "true"

$lta = 'C:\Program Files\LieberLieber\LemonTree.Automation\LemonTree.Automation.exe'
$gitcmd = 'C:\Program Files\Git\git-cmd.exe'

git rebase main

while($LASTEXITCODE -ne 0) {
    &$gitcmd "git cat-file blob HEAD:DemoModel.eapx | git lfs smudge > DemoModel_base.eapx & exit"
    &$gitcmd "git cat-file blob REBASE_HEAD:DemoModel.eapx | git lfs smudge > DemoModel_mine.eapx & exit"

    &$lta merge --Theirs DemoModel_base.eapx --Mine DemoModel_mine.eapx --out DemoModel.eapx

    git add DemoModel.eapx
    Remove-Item -Path DemoModel_base.eapx
    Remove-Item -Path DemoModel_mine.eapx

    git rebase --continue
}

$env:GIT_EDITOR = ""