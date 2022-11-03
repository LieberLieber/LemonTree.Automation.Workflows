GitHub Actions and other Example Scripts to be used with LemonTree.Automation and Sparx Systems Enterprise Architect Models
==================================
Disclaimer: we use this Repo to develop and test the scripts.
This Repo contains:
* DemoModel.eapx
* GitHub Actions that automate and support the handling of Sparx Systems Enterprise Architect Models with LemonTree.Automation
* A set of generic scripts to be used with LemonTree.Automation in other environments Jenkins, Teamcity, Azure Devops, ... https://github.com/LieberLieber/LemonTree.Automation.Workflows/tree/main/example-scripts

The full documentation on LemonTree.Automation can be found here: https://help.lieberlieber.com/display/LTA/LemonTree.Automation

Automation of model handling workflows
==================================
This folder contains automation workflows and actions which facilitate pull-request-based workflows with binary architecture models.

# Requirements towards Repository
Enterprise Architect files are binaries with usually several MB of size.
Storing these files directly in the repository leads to a fast growth and unnecessarily large downloads for clone and pull operations.
GIT LFS provides a transparent solution which stores only hashes of the binaries in the repository and hosts the large binaries in an artifactory.
The handling of the artifactory backend is transparent for the user in all ususal operations.
The current version of the workflows assumes, that the models are stored in LFS.

When you have no transparent access to the internet, make sure to set your HTTP proxy properly

`git config --global http.proxy http://myusername:mypassword@myproxyserver:8080`

# Requirements for Action Runners
To support the current setup, the used runner has to be `self-hosted` on `Windows`.
* LemonTree.Automation has to be installed in the default directory and a valid license has to be accessible from the context of the `lemontree` runner.
* both powershell and pwsh (powershell core) are supported - to be platform independ we set everything to pwsh now.  (shell: powershell/pwsh)

# Explanation of Workflows
## Customization by environment variables
* ModelName: name of the eapx file without extension
* LemonTreeAutomationFolder: installation folder of LemonTree.Automation, by default `C:\Program Files\LieberLieber\LemonTree.Automation`
* ReviewSessionURL: URL to JFrog artifactory, which is used as binary repository for review session files
* GitHubProjectRoot: Repository root URL on GitHub, e.g. https://github.com/LieberLieber/LemonTree.Automation.Workflows
* curl: Path to `curl.exe`, e.g. C:\Program Files\Git\mingw64\bin\curl.exe

#### Customization by secrets
* ARTIFACTORYUSER: user for access to artifactory
* ARTIFACTORYTOKEN: token for access to artifactory
* PAT: token for write access to repository, needed to trigger actions on pushing merge commit

## PublishReviewSession
Executed on each (re-)opening of and on each new commit in a pull-request.
Check if pull request can be merged automatically or if conflicting changes are present inside the model.
Generate a review-session file, upload it to artifactory and post a message in the pull request containing conflict status and a link to the review session

## UpdateReviewSessionFilesPullRequestsBaseCommit
Executed on each commit on a target branch of a pull-request.
Check if pull request can be merged automatically or if conflicting changes are present inside the model.
Generate a review-session file, upload it to artifactory and post a message in the pull request containing conflict status and a link to the review session.

## TriggerMergeByComments
Merge down the pull request on `/merge/` comment in the PR. Perform a merge of the architecture model, commit and push the changes.
This automatically closes the pull request and deletes the feature branch.

## PublishComponents
On push to Master the LemonTree Components defined in the Model specified in the Environment are written to disk. In the next steps they are published as artifacts.
The MPMS packages are then imported on a "Pro Cloud" repository and can be accesed via: https://test.lieberlieber.com/webea/index.php?m=3
Additionally the "LemonTree Component" files are also published on a Nexus artifact repository: https://nexus.lieberlieber.com/#browse/browse:lemontree-component
On a Desktop you can pull the published LemonTree Components to a LemonTreeComponents Repository folder using example-scripts/powershell/DownloadComponents.ps1

## ConsistencyCheck
On push the model consistency check is run, for now the results are just in the action output
 
