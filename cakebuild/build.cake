#addin "Cake.Incubator&version=6.0.0"
#addin "Cake.FileHelpers&version=4.0.1"

#tool "nuget:?package=GitVersion.CommandLine&version=5.5.0"
#tool "nuget:?package=NUnit.ConsoleRunner&version=3.12.0"
#tool "nuget:?package=NUnit.Extension.TeamCityEventListener&version=1.0.7"

var gitPath = EnvironmentVariable("TEAMCITY_GIT_PATH") ?? "git";

bool isMaster;
bool isSupport;
bool isDevelop;
bool isFeature;
bool isComponentsFeature;
string currentBranch;

string lemonTreeAutomation = @"C:\tools\LemonTree.Automation\LemonTree.Automation.exe";
string lemonTreeAutomationSetFilter = @"src\SetFilterInSessionFile\bin\Release\SetFilterInSessionFile.exe";
string lemonTreeRemovePrerendredDiagrams = @"src\RemovePrerenderedDiagrams\bin\Release\RemovePrerenderedDiagrams.exe";
string projectTransfer = @"C:\tools\ProjectTransfer\ProjectTransferUM.exe";
string packagerPath = @"C:\tools\LemonTree.Packager.CLI_3.1.4-lee-xxxx-nw-pack0004\LemonTree.Packager.CLI.exe";
string modelsPath = @"C:\tools\Models\";
string solution = @"src/ModelMetric.sln";


string shortcutToMaster = modelsPath + "LL_TEST_MASTER.EAP";
string shortcutToDevelop = modelsPath + "LL_TEST_DEVELOP.EAP";
string shortcutToComponents = modelsPath + "LL_TEST_COMPONENTS.EAP";

string localEap = "PWC.eapx";
string components = @"\Components\*.mpms";

bool stashedChanges = false;

Setup(context => 
{
	if(BuildSystem.IsLocalBuild)
	{
		Information("Stashing local changes to re-apply them after the build.");

		var result = ExecuteGitCommand("status --ignore-submodules --porcelain -- \":(exclude)build.cake\"");

		if(result.Output.Count != 0)
		{
			ExecuteGitCommand("stash push --keep-index --include-untracked -m cake-build-stash -- \":(exclude)build.cake\"");
			ExecuteGitCommand("stash apply");
			stashedChanges = true;
		}
	}
});

Teardown(context => 
{
	if(BuildSystem.IsLocalBuild && stashedChanges)
	{
		Information("Recreating working copy state at the start of the build.");
		
		ExecuteGitCommand("stash push -- \":(exclude)build.cake\"");
		ExecuteGitCommand("stash drop");
		ExecuteGitCommand("stash pop --index");
	}
});

TaskSetup(setupContext =>
{
   if(TeamCity.IsRunningOnTeamCity)
   {
      TeamCity.WriteStartBuildBlock(setupContext.Task.Description ?? setupContext.Task.Name);
      TeamCity.WriteStartProgress(setupContext.Task.Description ?? setupContext.Task.Name);
   }
});

TaskTeardown(teardownContext =>
{
   if(TeamCity.IsRunningOnTeamCity)
   {
      TeamCity.WriteEndProgress(teardownContext.Task.Description ?? teardownContext.Task.Name);
      TeamCity.WriteEndBuildBlock(teardownContext.Task.Description ?? teardownContext.Task.Name);
   }
});


Task("FetchGit")
	.Description("Reset the working copy if necessary, fetch all tags")
	.WithCriteria(() => !BuildSystem.IsLocalBuild)
    .Does(() =>
{
	Information("The git path is " + gitPath);

	ExecuteGitCommand("reset --hard");
	ExecuteGitCommand("clean -d -f ./src/");
	ExecuteGitCommand("config --system lfs.concurrenttransfers 100");
	ExecuteGitCommand("fetch --all --tags");
});

Task("Build")
	.IsDependentOn("FetchGit")
	.Does(() =>
{
	MSBuild(solution, new MSBuildSettings {
    ToolVersion = MSBuildToolVersion.VS2019,
    Configuration = "Release",
    PlatformTarget = PlatformTarget.x86,
	 Restore = true
    });
});

Task("Unittests")
	.IsDependentOn("Automation")	
	.IsDependentOn("Build")
	.Does(() =>
{
	var nunitSettings = new NUnit3Settings() 
	{
		SkipNonTestAssemblies = true,
		TeamCity = true,
		X86 = true,
		Results = new [] 
		{ 
			new NUnit3Result { FileName = "./nunit.tcr" },
			new NUnit3Result 
				{ 
					FileName = "./PrettyReport.html", 
					Transform = "./nunit3-xunit.xslt"
				} 
		},
		Agents = 1
	};
	
	NUnit3("./src/**/bin/**/*.Test.dll", nunitSettings);
	
	if(TeamCity.IsRunningOnTeamCity)
	{
		TeamCity.ImportData("nunit", "./nunit.tcr");
	}
});

Task("Automation")
.IsDependentOn("Build")
.Does(()=>
{
	var gitVersion = GitVersion(new GitVersionSettings());
	
	isMaster = gitVersion.BranchName == "main";
	isSupport = gitVersion.BranchName.StartsWith("support/");
	isFeature = gitVersion.BranchName.StartsWith("feature/") || gitVersion.BranchName == "review";
	isComponentsFeature = gitVersion.BranchName.StartsWith("feature/PackagerIntegration");
	isDevelop = !isMaster && !isSupport && !isFeature;
	currentBranch = gitVersion.BranchName; 
	
	Information($"Branchname: {gitVersion.BranchName}");
	Information($"isMaster: {isMaster}");
	Information($"isSupport: {isSupport}");
	Information($"isDevelop: {isDevelop}");
	Information("isFeature: "+ isFeature);
	Information("isComponentsFeature: "+isComponentsFeature);
	Information("isFeature: "+ isFeature);
	Information("isComponentsFeature: "+isComponentsFeature);

	if (isMaster)
	{
		TransferEapToDatabase(localEap, shortcutToMaster);
	}

	if (isDevelop)
	{
		TransferEapToDatabase(localEap, shortcutToDevelop);
		//There's no straight-forward way to determine the branch to compare to for an arbitrary branch.
		//There are some implementations for determining the "parent" branch on stackoverflow, but I'm not sure if that's even the right choice,
		//and they also need additional tool support (grep) to work.
		CompareTo("main",currentBranch);
	}

	if(isFeature)
	{
		CompareTo("develop",currentBranch);
	}	

	if (isComponentsFeature)
	{
		PublishComponents(components,shortcutToComponents);
	}
}
);

Task("Default")
	.IsDependentOn("Unittests")	
	.Does(() =>
{
	
	
	/**if(TeamCity.IsRunningOnTeamCity)
	'{
	'	Information("Publish pretty report.");		
	'	TeamCity.PublishArtifacts("./PrettyReport.html");
	'}**/
	
	Information("Build Finished");
});


public void CompareTo(string branchName,string currentBranch)
{
	// Use LT Automation to compare the latest commit of the current branch to the latest commit of the branch given as a parameter.
	// The base for the comparison is the merge-base between the branches.
	
	var result = ExecuteGitCommand("rev-parse head");
	var headCommitId = result.Output[0];
	result = ExecuteGitCommand($"rev-parse {branchName}");
	var targetBranchCommitId = result.Output[0];
	result = ExecuteGitCommand($"merge-base {headCommitId} {targetBranchCommitId}");
	var mergeBaseCommitId = result.Output[0];
	
	Information($"Head commit id: {headCommitId}");
	Information($"{branchName} commit id: {headCommitId}");
	Information($"MergeBase commit id: {mergeBaseCommitId}");

	string headPath = $"automation/head.eap";
	string targetBranchPath = $"automation/targetBranch.eap";
	string previousCommitPath = $"automation/previousCommit.eap";
	string mergeBasePath = $"automation/mergeBase.eap";
	string sessionMergeFilePath = $"automation/LTMergeTest.ltsfs";
	string sessionDiffFilePath = $"automation/LTDiffLastCommit.ltsfs";

	EnsureDirectoryExists("automation");

	//The order of checkouts is important here.
	//Since this manipulates the file in the repo, doing it for the file which is supposed to be there 
	//sets it back to how it was supposed to be.
	ExtractFileVersion(targetBranchCommitId, targetBranchPath);
	ExtractFileVersion(mergeBaseCommitId, mergeBasePath);
	ExtractFileVersion(headCommitId, headPath);
	
	
	//diagramimagemaps create false conflicts so we clean em out.
	ExecuteCommand(lemonTreeRemovePrerendredDiagrams,mergeBasePath);
	ExecuteCommand(lemonTreeRemovePrerendredDiagrams,headPath);
	
	ExecuteCommand(lemonTreeRemovePrerendredDiagrams,targetBranchPath); // If you commment out this line there will be no conflicts but DIAGRAMIMAGEMAP will allways be new



	result = ExecuteCommand(lemonTreeAutomation, $"merge --theirs {targetBranchPath} --mine {headPath} --base {mergeBasePath} --out=automation/out.eap --sfs {sessionMergeFilePath}");
	var resultMerge = result;
		// I want to run the diff also if a merge conflict happend.
		// This should give us the previous commmit on the same branch - currently not working
		result = ExecuteGitCommand($"rev-parse {currentBranch}~1");
		var previousCommitId = result.Output[0];
		Information($"rev-parse output: {result.Output[0]}");
		ExtractFileVersion(previousCommitId, previousCommitPath);
		ExecuteCommand(lemonTreeRemovePrerendredDiagrams,previousCommitPath);
	
		//result = ExecuteCommand(lemonTreeAutomation, $"diff --theirs {headPath} --mine {previousCommitPath} --sfs {sessionDiffFilePath}");
		//workaround as long as diff will not write ltsfs files.
		result = ExecuteCommand(lemonTreeAutomation, $"diff --theirs {previousCommitPath} --mine {headPath} --sfs {sessionDiffFilePath}");
		
		//if there is no differences in the modle delete the session file.
		if (!result.Output.Contains("Found 0 different elements."))
		{
			
			var resultUpdateFilterDiff= ExecuteCommand(lemonTreeAutomationSetFilter, $"{sessionDiffFilePath} \"\" \"$HideGraphicalChanges \"");
		}
		else
		{
			Information($"Deleting Session File {sessionDiffFilePath} because the models are identical");
			DeleteFile(sessionDiffFilePath);
		}
		

	if(resultMerge.ExitCode == 3)
	{
		var resultUpdateFilterMerge= ExecuteCommand(lemonTreeAutomationSetFilter, $"{sessionMergeFilePath} \"#Conflicted\" \"$HideGraphicalChanges \"");
		Information($"LemonTree Automation has detected a conflict between the current branch and branch {branchName}.");
		TeamCity.BuildProblem("Conflict in file PWC.eapx detected.");
		throw new Exception("Conflict in file PWC.eapx detected.");
	}
	
	
	
}

public void ExtractFileVersion(string commitId, string targetPath)
{
	//Git Restore replaces the version of the file in the repo with the one in the given commit.
	ExecuteGitCommand($"restore -s {commitId} -- {localEap}");

	if(FileExists(targetPath))
	{
		Information($"Deleting old version of {targetPath}");
		DeleteFile(targetPath);
	}
	CopyFile(localEap, targetPath);
	
}


public void PublishComponents(string source, string target)
{
			//Can be also a pattern so this makes no sense
			//if (!FileExists(source))
			//{
			//	Error(source + " does not exist");
			//}
	
			if (!FileExists(target))
			{
				Error(target + " does not exist");
			}
			
			string arguments = $" install -i {source} -o {target}";
			int exitCode = ExecuteCommand(packagerPath, arguments).ExitCode;
			
			if (exitCode != 0)
			{
				// lets break the build
				TeamCity.BuildProblem($"{packagerPath} failed ");
				throw new Exception("Build failed. See build log for more information.");
			}	
}

public void TransferEapToDatabase(string source, string target)
{
			if (!FileExists(source))
			{
				Error(source + " does not exist");
			}
	
			if (!FileExists(target))
			{
				Error(target + " does not exist");
			}
			
			string arguments = $"--source={source} --target={target} --loglevel=Debug";
	var result = ExecuteCommand(projectTransfer, arguments);
			
	if (result.ExitCode != 0)
			{
				// lets break the build
				TeamCity.BuildProblem($"{projectTransfer} failed ");
				throw new Exception("Build failed. See build log for more information.");
			}	
}

public CommandResult ExecuteGitCommand(string arguments)
{
	return ExecuteCommand(gitPath, arguments);
}

public CommandResult ExecuteCommand(string tool, string arguments)
{
	var commandResult = new CommandResult();

		Information($"{tool} {arguments}");
		
		int exitCode = StartProcess(tool, new ProcessSettings
		{
			Arguments = arguments,
			RedirectStandardOutput = true,
			RedirectStandardError = true,
			RedirectedStandardOutputHandler = (line) => 
			{
				if(line != null)
				{
					Information(line);
				commandResult.Output.Add(line);
				}
				return line;
			},
			RedirectedStandardErrorHandler = (line) => 
			{
				if(line != null)
				{
					Error(line);
				commandResult.Errors.Add(line);
				}
				return line;
			}		 
		});
		Information(tool + " exited with code: " + exitCode);	
	commandResult.ExitCode = exitCode;
	return commandResult;
}

public class CommandResult
{
	public int ExitCode { get; set; }
	public List<string> Output { get; private set; }
	public List<string> Errors { get; private set; }

	public CommandResult(){
		Output = new List<string>();
		Errors = new List<string>();
	}
}

var target = Argument("target", "Default");
RunTarget(target);
