$env:GIT_EDITOR = "true"
          
$lta = 'C:\Program Files\LieberLieber\LemonTree.Automation\LemonTree.Automation.exe'
$gitcmd = 'C:\Program Files\Git\git-cmd.exe'

git rebase origin/main

while($LASTEXITCODE -ne 0) {
	$status = git status -s -uno
	$expected_status = "UU DemoModel.eapx"
              
              if($actual_status -ne $expected_status) {
		Write-Output "::error::Model is not conflicted please rebase manually."
		exit 666
	}
	
	$basecommit = git merge-base HEAD REBASE_HEAD
	$command = 'git cat-file blob {0}:DemoModel.eapx | git lfs smudge > DemoModel_base.eapx & exit' -f $basecommit
	#this is required to get rid of the line feeds in the basecommit string
	&$gitcmd $command
	&$gitcmd "git cat-file blob HEAD:DemoModel.eapx | git lfs smudge > DemoModel_mine.eapx & exit"
	&$gitcmd "git cat-file blob REBASE_HEAD:DemoModel.eapx | git lfs smudge > DemoModel_theirs.eapx & exit"

	&$lta merge --Base DemoModel_base.eapx --Theirs DemoModel_theirs.eapx --Mine DemoModel_mine.eapx --out DemoModel.eapx

	if($LASTEXITCODE -eq 0){
		Write-Output "No merge conflicts, setting message"
	}
	elseif($LASTEXITCODE -eq 2){
		Write-Output "::error::Internal Error when diffing. Please report such errors to support@lieberlieber.com"
		exit 2
	}
	elseif($LASTEXITCODE -eq 3){
		Write-Output "Merge conflicts present, auto-merge failed"
		exit 3
	}
	elseif($LASTEXITCODE -eq 6){
		Write-Output "::warning::Licensing issue of LemonTree.Automation"
		exit 6
	}
	else{
		Write-Output "::error::Unknown error"
		exit 1
	}

	git add DemoModel.eapx

	Remove-Item -Path DemoModel_base.eapx
	Remove-Item -Path DemoModel_theirs.eapx
	Remove-Item -Path DemoModel_mine.eapx

	git rebase --continue
}

$env:GIT_EDITOR = ""