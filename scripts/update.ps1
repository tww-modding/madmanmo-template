$ErrorActionPreference = "Stop";
$VerbosePreference = "Continue";

$here = Split-Path $script:MyInvocation.MyCommand.Path;
$rootDirectoryPath = & "$here\_Find-RootDirectory.ps1" -SearchStart $here;

Write-Verbose "Checking new update_commands for changes";

$masterUpdateCommandsPath = "$rootDirectoryPath\src\changes\update_commands.txt";

$workingUpdateCommandsPath = "$rootDirectoryPath\working\update_commands.txt";
$dummy = New-Item -ItemType File -Path $workingUpdateCommandspath -Force;

$importingUpdateCommandsPath = "$rootDirectoryPath\src\assembly_kit\raw_data\db\update_commands.txt";

# copy it to a working directory, changing the encoding to UTF-8 (so it can be diffed in git and show changes)
$content = Get-Content $importingUpdateCommandsPath
[System.IO.File]::WriteAllLines($workingUpdateCommandsPath, $content)

# check if different
$original = [System.IO.File]::ReadAllText($masterUpdateCommandsPath);
$new = [System.IO.File]::ReadAllText($workingUpdateCommandsPath);
 
if ($new -ne $original)
{
	Write-Verbose "Original update_commands and current are different. Copying and updating version";
	
	# increment the build version by 1
    $modFilePath = "$rootDirectoryPath\mod.json";
    $mod = ConvertFrom-Json ([System.IO.File]::ReadAllText($modFilePath));
	$oldVersion = "$($mod.version.breaking).$($mod.version.patch).$($mod.version.build)";
    $mod.version.build++;
	$newVersion = "$($mod.version.breaking).$($mod.version.patch).$($mod.version.build)";
	
	$versionDiffUpdateCommandsPath = "$rootDirectoryPath\src\changes\$oldVersion-$newVersion-diff-update_commands.txt";
	$diff = $new.Replace($original, "");
	
	[System.IO.File]::WriteAllText($versionDiffUpdateCommandsPath, $diff);
	
    # copy into expected location if different
    [System.IO.File]::WriteAllText($masterUpdateCommandsPath, $new);

	# Save versioning changes
    [System.IO.File]::WriteAllText($modFilePath, (ConvertTo-Json $mod));
}
else
{
	throw "No changes detected. No reason to build";
}