$ErrorActionPreference = "Stop";
$VerbosePreference = "Continue";

$here = Split-Path $script:MyInvocation.MyCommand.Path;
$rootDirectoryPath = & "$here\_Find-RootDirectory.ps1" -SearchStart $here;

Write-Verbose "Checking new update_commands for changes";

$masterUpdateCommandsPath = "$rootDirectoryPath\raw\update_commands.txt";

$workingUpdateCommandsPath = "$rootDirectoryPath\working\update_commands.txt";
$dummy = New-Item -ItemType File -Path $workingUpdateCommandspath -Force;

$importingUpdateCommandsPath = "$rootDirectoryPath\assembly_kit\raw_data\db\update_commands.txt";

# copy it to a working directory, changing the encoding to UTF-8 (so it can be diffed in git and show changes)
$content = Get-Content $importingUpdateCommandsPath
[System.IO.File]::WriteAllLines($workingUpdateCommandsPath, $content)

# check if different
$original = [System.IO.File]::ReadAllText($masterUpdateCommandsPath);
$new = [System.IO.File]::ReadAllText($workingUpdateCommandsPath);
 
if ($new -ne $original)
{
	Write-Verbose "Original update_commands and current are different. Copying and updating version";
    # copy into expected location if different
    [System.IO.File]::WriteAllText($masterUpdateCommandsPath, $new);

    # increment the minor version by 1
    $modFilePath = "$rootDirectoryPath\mod.json";
    $mod = ConvertFrom-Json ([System.IO.File]::ReadAllText($modFilePath));
    $mod.version.patch = $mod.version.patch + 1;

    [System.IO.File]::WriteAllText($modFilePath, (ConvertTo-Json $mod));
}
else
{
	Write-Verbose "Original update_commands and current are the same. No changes detected";
}