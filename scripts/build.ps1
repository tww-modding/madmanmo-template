$ErrorActionPreference = "Stop";

$here = Split-Path $script:MyInvocation.MyCommand.Path;
$rootDirectoryPath = & "$here\_Find-RootDirectory.ps1" -SearchStart $here;

& "$here\update.ps1";

# DAVE Export
#$answer = Read-Host -Prompt "Have you done an export from DAVE? (y/n)";
#if ([String]::IsNullOrEmpty($answer) -or $answer -ne "y")
#{
#	throw "No point doing a build if there is no exported data";
#}

$modFilePath = "$rootDirectoryPath\mod.json";
$mod = ConvertFrom-Json ([System.IO.File]::ReadAllText($modFilePath));

$version = "$($mod.version.breaking).$($mod.version.patch).$($mod.version.build)"
$name = $mod.name;

Write-Verbose "Building [$name] version [$version]"

$buildFolder = "$rootDirectoryPath\build\$version";
$packedFolder = "$buildFolder\packed";
$rawFolder = "$buildFolder\raw";
$packFilePath = "$packedFolder\$name-$version.pack";
$imageFilePath = "$packedFolder\$name-$version.png";
$changesFilePath = "$packedFolder\$name-$version.txt";

if (-not (Test-Path $packedFolder))
{
	$result = New-Item -ItemType Directory -Path $packedFolder;
}

if (-not (Test-Path $rawFolder))
{
	$result = New-Item -ItemType Directory -Path $rawFolder;
}

function _GenerateChangesFile
{
	[CmdletBinding()]
	param
	(
		[string]$version,
		[string]$destination
	)

	$changeFileContent = "";

	$regex = "^(?<fromVersion>[0-9]+\.[0-9]+\.[0-9]+)\-(?<toVersion>[0-9]+\.[0-9]+\.[0-9]+).*\.txt$";
	$changeFileProcessingScript = { 
		if ($_.Name -match $regex) 
		{  
			$fromVersion = [Version]::Parse($matches."fromVersion");
			$toVersion = [Version]::Parse($matches."toVersion");

			$currentVersion = [Version]::Parse($version);
			if ($toVersion -gt $currentVersion)
			{
				Write-Verbose "Change file [$($_.Name)] from version [$fromVersion] was greater than the version being built [$currentVersion]. It will be excluded from the change notes";
			}
			else 
			{
				return new-object psobject @{Path=$_.FullName;FromVersion=$fromVersion;ToVersion=$toVersion;}
			}
		}
		else 
		{
			Write-Verbose "Change file [$($_.Name)] did not match regex [$regex]. It will be excluded from the change notes";
		}
	}
	$changeFiles = @(Get-ChildItem -Path "$rootDirectoryPath\src\changes" -Recurse | ForEach-Object $changeFileProcessingScript | Sort-Object -Property ToVersion);
	foreach ($file in $changeFiles)
	{
		$content = [System.IO.File]::ReadAllText($file.Path);
		$changeFileContent = "$($file.FromVersion)-$($file.ToVersion)" + [Environment]::NewLine + $content + $changeFileContent;
	}

	$item = New-Item -ItemType File -Path $destination -Force;
	[System.IO.File]::WriteAllText($item.FullName, $changeFileContent);
}

$pack = Copy-Item -Path "$rootDirectoryPath\build\template.pack" -Destination $packFilePath -Force
$image = Copy-Item -Path "$rootDirectoryPath\src\images\mod.png" -Destination $imageFilePath -Force
$changes = _GenerateChangesFile -version $version -destination $changesFilePath;

# Clean up the DAVE export and copy to the build folder
$binaryOutput = "$rootDirectoryPath\src\assembly_kit\working_data\db";
if (Test-Path $binaryOutput)
{
	$binaryDestination = "$rawFolder\db";

	# we copy all files greater than 100 bytes because that seems to be the size of the empty
	# binary files
	& robocopy $binaryOutput $binaryDestination /E /MIN:100
}

$textOutput = "$rootDirectoryPath\src\assembly_kit\working_data\text";
if (Test-Path $textOutput)
{
	$testDestination = "$rawFolder\text";

& robocopy $textOutput $testDestination /E
}

& "$rootDirectoryPath\tools\pfm-4.1.2\PackFileManager.exe" $packFilePath

$answer = Read-Host -Prompt "Finalise build? This will commit everything to source control and tag with the version (y/n)";
if ($answer -eq "y")
{
	& git add -A;
	& git commit -m "Packed build [$version]";
	& git tag $version;
}