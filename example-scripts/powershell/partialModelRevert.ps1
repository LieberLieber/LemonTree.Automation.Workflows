$Model ="DemoModel.eapx"
$commitId = git rev-parse HEAD
Echo "Head CommitID $commitID"
$fileReference = $commitID+":"+$Model
Echo $fileReference

            $pointer = git cat-file blob $fileReference
            Echo "Head Pointer $pointer"
            $sha = ($pointer[1] -split(":"))[1]
          if($sha -ne $null){
            $shaPart1 = $sha.Substring(0,2)
            $shaPart2 = $sha.Substring(2,2)
            echo "Model SHA: $sha"
            git cat-file --filters $fileReference | Out-Null
            copy ".git\lfs\objects\$shaPart1\$shaPart2\$sha" "HEAD_$Model"
            echo "::set-output name=result::downloaded"
          }
          else{
            echo "::set-output name=result::notFound"
          }